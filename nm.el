(provide 'nm)

(defun nm/remove-trailing-spaces (stringlist)
  "Remove trailing spaces from the list"
  (message (format "%s" stringlist))
  (mapcar (lambda (x) (replace-regexp-in-string " +$" "" x)) stringlist))


(defun nm/return-nmcli-output (arg)
  "Return nmcli output that is parsed and good looking."
  (cond
   ((equal "active-profiles" arg)
    (split-string (shell-command-to-string
                                 "nmcli -t -f NAME connection show --active") "\n" t " +"))
   
   ((equal "active-profile-details" arg)
    (let* ((output (shell-command-to-string "nmcli connection show --active"))
           (sub (substring output 0 (- (length output) 1))))
      (format sub)))
    
   ((equal "profiles" arg)
    ;; All profiles
    (split-string (shell-command-to-string
                   "nmcli -t -f NAME connection show") "\n" t " +"))
   ((equal "aps-details" arg)
    ;; Connection details
    (let* ((output (shell-command-to-string "nmcli -f SSID,SIGNAL,SECURITY,CHAN,ACTIVE,BSSID device wifi list"))
           (sub (substring output 0 (- (length output) 1))))
      (format sub)))

   ((equal "aps" arg)
    ;; Available WiFi APs
    (split-string (shell-command-to-string
                   "nmcli -t -f SSID device wifi") "\n" t " +"))))


(defun nm/show-aps-list ()
  "List WiFi APs with detailed info in a temp buffer."
  (interactive)
  (with-temp-buffer
   (princ (nm/return-nmcli-output "aps-details"))))



(defun nm/show-active-connections-profiles ()
  "Show nm profiles that are active."
  (interactive)
  (with-temp-buffer
    (princ (nm/return-nmcli-output "active-profile-details"))))


(defun nm/connect-to-wifi-network (network password)
  "Connect to a Wifi network and create NetworkManager profile.

This will create a NetworkManager profile with the SSID as the profile NAME."
  
  (interactive
   (list
    (completing-read "Network: " (nm/return-nmcli-output "aps"))
    (read-string "Password: ")))
  (let* ((fstr (format "nmcli device wifi connect %s password %s" network password)))
    (let ((output (shell-command-to-string (format "%s" fstr))))
      (message (format output)))))
