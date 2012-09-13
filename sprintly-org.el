(require 'json)
(defcustom sprintly-user-name ""
  "Sprintly email that authenticates with sprintly")
(defcustom sprintly-token ""
  "Sprintly API token")
(defcustom sprintly-assignee-id ""
  "Sprintly user ID that will be query for items")
(defcustom sprintly-product-id ""
  "Sprintly product ID that will be use to retrieve items")
(defvar sprintly-base-api "https://sprint.ly/api/")

(defvar sprintly-block-authorisation nil
  "Flag whether to block url.el's usual interactive authorisation procedure")

(defun sprintly-active-items-url ()
  (format "%s/%s/%s/items.json?assigned_to=%s&status=%s"
                sprintly-base-api
                "products"
                sprintly-product-id
                sprintly-assignee-id
                "in-progress"))

(defadvice url-http-handle-authentication (around xyz-fix)
  (unless sprintly-block-authorisation
    ad-do-it))
(ad-activate 'url-http-handle-authentication)

(defun get-json (url)
  (let ((buffer (url-retrieve-synchronously url))
        (json nil))
    (save-excursion
      (set-buffer buffer)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (setq json (buffer-substring-no-properties (point) (point-max)))
      (kill-buffer (current-buffer)))
    json))

(defun get-and-parse-json (url)
    (let ((json-object-type 'plist))
          (json-read-from-string
                (get-json url))))

(defun retrieve-elem-info (plem)
  (let ((number (plist-get plem :number))
        (type (plist-get plem :type))
        (title (plist-get plem :title)))
        (insert (format "* TODO %s #%d\n  Description: %s\n" type number title))))

(defun retrieve-todos-entries (url)
  (let ((json (get-and-parse-json url)))
        (mapcar 'retrieve-elem-info json)))

(defun insert-sprintly-active-items ()
  (interactive)
  (let ((sprintly-block-authorisation t)
        (url-request-method "GET")
        (url-request-extra-headers
         `(("Content-Type" . "application/xml")
           ("Authorization" . ,(concat "Basic "
                                       (base64-encode-string
                                        (concat sprintly-user-name ":" sprintly-token)))))))
    (retrieve-todos-entries sprintly-active-items-url)))

(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key "\M-n"
                           'insert-sprintly-active-items)))
(provide 'sprintly-org)
