Sprintly Org Mode Integration
=================

Expiremental plugin to integrate sprintly with org-mode. Right now it only support one simple functionality.
It creates TODO items from your sprintly account. The TODOS will have the following format.

    * TODO type #number
      Description: title

Where type, number and title correspond to the sprintly [API definitions](http://support.sprint.ly/kb/api/items).

    (setq sprintly-user-name "user@email.com")
    (setq sprintly-token "xxxxxxxx")
    (setq sprintly-assignee-id "id")
    (setq sprintly-product-id "id")

The assignee-id should be the id of the user that you want the items to be retrieve it from.