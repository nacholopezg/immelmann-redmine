# ✨  redmine_issue_dynamic_edit
Add new interactive elements to the issue detail page to **dynamically update an issue’s attributes and custom fields**, directly within the details block, and **without any page refresh** (*JIRA-style inline editing*).


### 🔴  What to include when opening an issue
>Please list:
>- The Redmine version you use
>- All installed plugins
>
>Conflicts may occur if another plugin modifies the same page elements.
>
>This plugin uses JavaScript extensively.
>
>Open your browser’s JS console ([HowTo](https://webmasters.stackexchange.com/a/77337)), reproduce the problem, and review the console output.
>Copy and paste the result into your GitHub issue and expand any relevant objects (for example, error data).
>
>These details will help identify whether the problem comes from an AJAX request or a JavaScript error.

### 🔎  Example

![Gif that represents dynamic edition of field from the detailled issue's view](/doc/edit.gif)

### 📦  Installation

* Clone the repository into your Redmine `plugins` directory : `git clone https://github.com/Ilogeek/redmine_issue_dynamic_edit.git` (ensure the folder name is `redmine_issue_dynamic_edit`)
* Restart your Redmine instance

### ⚙  Configuration

You can adjust the following options from Redmine’s Administration → Plugins → redmine_issue_dynamic_edit panel:
* **\_CONF\_FORCE\_HTTPS** : forces all AJAX calls to use HTTPS (recommended to avoid Mixed Content issues). 
* **\_CONF\_DISPLAY\_EDIT\_ICON** : controls how pencil icons appear for editable fields — set to single (hover each field individually) or block (hovering the details block shows all icons)
* **\_CONF\_LISTENER\_TYPE\_VALUE** : defines the event type (`none`, `click`, `dblclick`) that opens an editor from the field value
* **\_CONF\_LISTENER\_TYPE\_ICON** : defines the event type for the pencil icon (defaults to the same as `_CONF_LISTENER_TYPE_VALUE`)
* **\_CONF\_LISTENER\_TARGET** : defines the clickable area that triggers editing
* **\_CONF\_EXCLUDED\_FIELD\_ID** : comma-separated list of field IDs to exclude from editing (e.g. `TitleInput`, `DescriptionInput`, `statusListDropdown`)
* **\_CONF\_CHECK\_ISSUE\_UPDATE\_CONFLICT** : if enabled, prevents overwriting changes made by other users.

### 🎨  Customization

You can customize the visual style in `assets/stylesheets/issue_dynamic_edit.css` to better match your theme. 

### 🆕  Changelog

* **v 0.9.3** : Add admin panel to settings section, fixes #127 #126 #96
* **v 0.9.2** : JSToolbar fixed (#100)
* **v 0.9.1** : Check version improved (avoiding update conflicts) : using [Redmine REST API](https://www.redmine.org/projects/redmine/wiki/rest_issues) and disabling check when tab is not focused (#97)
* **v 0.9.0** : JS rewritten to remove jQuery code
* **v 0.8.1** : fixed Github issue #89 : Issue version check (AJAX call) may give glitch while editing text + disable global event listener on ajaxSend
* **v 0.8.0** : Complete rework. Compatible with last Redmine version. New settings added : `_CONF_CHECK_ISSUE_UPDATE_CONFLICT` (#70 #88). Removed external lib (FontAwesome) (#74). Mobile style added (#87). Print style added (#84). Bug fix (#79, #85)
* **v 0.7.2** : New settings added into config file (`_CONF_DISPLAY_EDIT_ICON` and `_CONF_LISTENER_TYPE_ICON`) see Configuration part for more info ; new event `none` for `_CONF_LISTENER_TYPE_VALUE` disabling listener on value ; css fix
* **v 0.7.1** : Fixed incorrect DOM structure if user has read only access to the issue (#61 #64)
* **v 0.7.0** : Category filter by project added (#55) and prevent dialog closing when using fa-pencil selector (#59)
* **v 0.6.9** : Category field support (Github request #54)
* **v 0.6.8** : Checkboxes custom fields fixed (#53)
* **v 0.6.7** : fixed Github issue #46 : text field focus issue
* **v 0.6.6** : New configuration file + Multiple fixes (#30 #31 #35 #36 #37 #38 #41)
* **v 0.6.5** : Checklists plugin support (and all other plugins that compute fields when there's an issue update) (Github requests #26 and #28) + custom url support (Github request #29)
* **v 0.6.4** : version field with checkbox display is now supported, Target version and Assignee fields are also supported (Github request #24)
* **v 0.6.3** : fixed Github issue #22 : DatepickerFallback raised an error
* **v 0.6.2** : fixed Github issue #22 : long description is now supported (no more 414 errors)
* **v 0.6.1** : fixed Github issue #20
* **v 0.6.0** : **NOW WITH CUSTOM FIELDS SUPPORT** ! (Github #19)
* **v 0.5.0** : fixed Github issue #18 : textarea fixed (jstoolbar or ckeditor)
* **v 0.4.9** : fixed Github issue #17 : Datepicker fallback added for date fields
* **v 0.4.8** : fixed Github issues #15 and #16
* **v 0.4.7** : if error on dynamic update, put back old values in details block (fixed Github issue #8)
* **v 0.4.6** : description is now dynamically editable (edit field appears if there's already a description written) (Github request #14)
* **v 0.4.5** : fixed Github issue #13 : CSS display for custom attributes, added Title dynamic edition (Github request #14)
* **v 0.4.4** : fixed Github issues #6, #12 : User can't update status until all required field are filled for this step of the issue
* **v 0.4.3** : partially fixed Github issue #12 : Read only attributes can't be edited anymore. Dynamic refresh for read only attributes when status changes
* **v 0.4.2** : fixed Github issue #10 : History list updated after modification
* **v 0.4.1** : fixed Github issue #7 : update status list to follow Redmine workflow
* **v 0.4.0** : fixed Github issues #2, #4, #9. Edited dropdown display
* **v 0.3.0** : start date, due date, ratio and estimated time fields are now dynamically editable. Translation files added (en, fr). Log added in console when AJAX fails
* **v 0.2.0** : fixed "conflict" when trying to add a note after an update from dropdowns. New method used, REST API is not required anymore
* **v 0.1.0** : initial commit
