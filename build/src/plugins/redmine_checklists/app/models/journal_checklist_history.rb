class JournalChecklistHistory
  def self.can_fixup?(journal_details)
    return false if journal_details.journal.nil?

    issue = journal_details.journal.journalized
    return false unless issue.is_a?(Issue)

    prev_journal_scope = issue.journals.order('id DESC')
    prev_journal_scope = prev_journal_scope.where('id <> ?', journal_details.journal_id) if journal_details.journal_id
    prev_journal = prev_journal_scope.first
    return false unless prev_journal

    return false if prev_journal.user_id != journal_details.journal.user_id
    return false if Time.zone.now > prev_journal.created_on + 1.minute

    prev_journal.details.all? { |x| x.prop_key == 'checklist' } &&
      journal_details.journal.details.all? { |x| x.prop_key == 'checklist' } &&
      journal_details.journal.notes.blank? &&
      prev_journal.notes.blank? &&
      prev_journal.details.select { |x| x.prop_key == 'checklist' }.size == 1
  end

  def self.fixup(journal_details)
    issue = journal_details.journal.journalized
    prev_journal_scope = issue.journals.order('id DESC')
    prev_journal_scope = prev_journal_scope.where('id <> ?', journal_details.journal_id) if journal_details.journal_id
    prev_journal = prev_journal_scope.first
    checklist_details = prev_journal.details.find{ |x| x.prop_key == 'checklist'}
    if new(checklist_details.old_value, journal_details.value).empty_diff?
      prev_journal.destroy
      # <PRO>
      journal_details.journal.send(:send_checklist_notification)
      # </PRO>
    else
      checklist_details.update_attribute(:value, journal_details.value)
      journal_details.journal.destroy unless journal_details.journal.new_record? && journal_details.journal.details.any?{ |x| x.prop_key != 'checklist'}
      # <PRO>
      prev_journal.send(:send_checklist_notification)
      # </PRO>
    end
  end

  def initialize(was, become)
    @was = force_object(was)
    @become = force_object(become)
    @was_ids = @was.map(&:id)
    @become_ids = @become.map(&:id)

    # <PRO>
    @added_ids = @become_ids - @was_ids
    @removed_ids = @was_ids - @become_ids
    # </PRO>
    @both_ids = @become_ids & @was_ids
  end

  def diff
    {
      # <PRO>
      :added => @become.select{ |x| @added_ids.include? x.id },
      :removed => @was.select{ |x| @removed_ids.include? x.id },
      :renamed => renamed,
      # </PRO>
      :undone => undone,
      :done => done
    }
  end

  def empty_diff?
    diff.all?{ |_,v| v.empty? }
  end

  def journal_details(opts = {})
    JournalDetail.new(opts.merge({
        :property  => 'attr',
        :prop_key  => 'checklist',
        :old_value => @was.map(&:to_h).to_json,
        :value     => @become.map(&:to_h).to_json
      }))
  end

  private

  def undone
    @both_ids.map do |id|
      was_is_done = was_by_id(id).is_done
      become_is_done = become_by_id(id).is_done
      if was_is_done != become_is_done && was_is_done
        become_by_id(id)
      else
        nil
      end
    end.compact
  end

  def done
    @both_ids.map do |id|
      was_is_done = was_by_id(id).is_done
      become_is_done = become_by_id(id).is_done
      if was_is_done != become_is_done && become_is_done
        become_by_id(id)
      else
        nil
      end
    end.compact
  end

  # <PRO>
  def renamed
    Hash[@both_ids.map do |id|
      was = was_by_id(id)
      became = become_by_id(id)
      [was, became] if was.subject != became.subject
    end.compact]
  end
  # </PRO>

  def was_by_id(id)
    @was.find{ |x| x.id == id }
  end

  def become_by_id(id)
    @become.find{ |x| x.id == id }
  end

  def force_object(unk)
    if unk.is_a?(String)
      json = JSON.parse(unk)
      json = [json] unless json.is_a?(Array)
      json.map{ |x| OpenStruct2.new(x.has_key?('checklist') ? x['checklist'] : x) }
    else
      unk.map{ |x| OpenStruct2.new(x.attributes) }
    end
  end
end
