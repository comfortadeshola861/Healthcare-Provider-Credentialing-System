;; Provider Identity Contract
;; Manages healthcare practitioner profiles

;; Data structures
(define-map providers
  { provider-id: principal }
  {
    name: (string-utf8 100),
    specialty: (string-utf8 100),
    contact-info: (string-utf8 200),
    active: bool,
    registration-date: uint
  }
)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_ALREADY_REGISTERED u2)
(define-constant ERR_NOT_FOUND u3)

;; Register a new provider
(define-public (register-provider
    (name (string-utf8 100))
    (specialty (string-utf8 100))
    (contact-info (string-utf8 200)))
  (let ((provider-id tx-sender))
    (if (is-some (map-get? providers { provider-id: provider-id }))
      (err ERR_ALREADY_REGISTERED)
      (ok (map-set providers
        { provider-id: provider-id }
        {
          name: name,
          specialty: specialty,
          contact-info: contact-info,
          active: true,
          registration-date: block-height
        }
      ))
    )
  )
)

;; Update provider information
(define-public (update-provider
    (name (string-utf8 100))
    (specialty (string-utf8 100))
    (contact-info (string-utf8 200)))
  (let ((provider-id tx-sender))
    (match (map-get? providers { provider-id: provider-id })
      provider-data (ok (map-set providers
        { provider-id: provider-id }
        (merge provider-data {
          name: name,
          specialty: specialty,
          contact-info: contact-info
        })
      ))
      (err ERR_NOT_FOUND)
    )
  )
)

;; Set provider active status
(define-public (set-active-status (active bool))
  (let ((provider-id tx-sender))
    (match (map-get? providers { provider-id: provider-id })
      provider-data (ok (map-set providers
        { provider-id: provider-id }
        (merge provider-data { active: active })
      ))
      (err ERR_NOT_FOUND)
    )
  )
)

;; Read-only function to get provider details
(define-read-only (get-provider (provider-id principal))
  (map-get? providers { provider-id: provider-id })
)
