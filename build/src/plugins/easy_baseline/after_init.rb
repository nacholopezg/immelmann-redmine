lib_dir = File.join(File.dirname(__FILE__), 'lib', 'easy_baseline')

# Redmine patches
patch_path = File.join(lib_dir, 'redmine_patch', '**', '*.rb')
Dir.glob(patch_path).each do |file|
  require file
end

# this block is runed once just after easyproject is started
# means after all plugins(easy) are initialized
# it is place for plain requires, not require_dependency
# it should contain hooks, permissions - base class in redmine is required thus is not reloaded
ActiveSupport.on_load(:easyproject, yield: true) do
  require 'easy_baseline/internals'
  require 'easy_baseline/hooks'

  Redmine::AccessControl.map do |map|
    map.project_module :easy_baselines do |pmap|
      pmap.permission :view_baselines, {
        easy_baselines: [:index, :show],
        easy_baseline_gantt: [:show]
      }
      pmap.permission :edit_baselines, {
        easy_baselines: [:create, :destroy, :new]
      }
    end
  end

end

# Here goes query registering, custom fields registering and so on
RedmineExtensions::Reloader.to_prepare do
end
