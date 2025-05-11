;;; gptel-mcp.el --- gptel mcp package               -*- lexical-binding: t; -*-

;; Copyright (C) 2025  lizqwer scott

;; Author: lizqwer scott <lizqwerscott@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1") (mcp "0.1.0") (gptel "0.9.8") (transient "0.7.4"))
;; Keywords: ai, mcp
;; URL: https://github.com/lizqwerscott/gptel-mcp.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'cl-lib)
(eval-when-compile (require 'transient))

(require 'mcp-hub)
(require 'gptel)

(defun gptel-mcp--get-tool-path (tool)
  "Get the category and name path from TOOL plist.
Returns a list in the form (CATEGORY NAME)."
  (list (plist-get tool :category)
        (plist-get tool :name)))

(defun gptel-mcp-register-tool ()
  "Register all available MCP tools with gptel."
  (interactive)
  (let ((tools (mcp-hub-get-all-tool :asyncp t :categoryp t)))
    (mapcar #'(lambda (tool)
                (apply #'gptel-make-tool
                       tool))
            tools)))

(defun gptel-mcp-activate-all-tool ()
  "Activate all MCP tools in current gptel session."
  (interactive)
  (let ((tools (mcp-hub-get-all-tool :asyncp t :categoryp t)))
    (dolist (tool tools)
      (push (gptel-get-tool (gptel-mcp--get-tool-path tool))
            gptel-tools))))

(defun gptel-mcp-deactivate-all-tool ()
  "Deactivate all MCP tools in current gptel session."
  (interactive)
  (let* ((tools (mcp-hub-get-all-tool :asyncp t :categoryp t))
         (tool-paths (mapcar #'gptel-mcp--get-tool-path tools)))
    (setq gptel-tools
          (cl-remove-if #'(lambda (tool)
                            (cl-find (list (gptel-tool-category tool)
                                           (gptel-tool-name tool))
                                     tool-paths
                                     :test #'equal))
                        gptel-tools))))

(defun gptel-mcp-start-all-server-and-register ()
  "Start all MCP servers and register their tools."
  (interactive)
  (mcp-hub-start-all-server
   #'(lambda ()
       (message "start all server finish!")
       (gptel-mcp-register-tool))))

;;;###autoload (autoload 'gptel-mcp-dispatch "gptel-mcp" nil t)
(transient-define-prefix gptel-mcp-dispatch ()
  "Dispatch menu for gptel-mcp operations.
Provides quick access to server management and tool activation commands."
  [["Mcp server"
    ("s" "Start all server" gptel-mcp-start-all-server-and-register)]
   ["Tools"
    ("A" "Active all" gptel-mcp-activate-all-tool)
    ("C" "Deactivate all" gptel-mcp-deactivate-all-tool)]]
  [("q" "Quit" transient-quit-all)])

(provide 'gptel-mcp)
;;; gptel-mcp.el ends here
