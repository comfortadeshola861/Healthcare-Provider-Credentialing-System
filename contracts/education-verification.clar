;; Education Verification Contract
;; Validates medical training credentials

;; Data structures
(define-map education-credentials
  { provider-id: principal, credential-id: uint }
  {
    institution: (string-utf8 100),
    degree: (string-utf8 100),
    year-completed: uint,
    verified: bool,
    verifier: (optional principal)
  }
)

(define-data-var credential-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_NOT_FOUND u3)

;; Add education credential
(define-public (add-credential
    (institution (string-utf8 100))
    (degree (string-utf8 100))
    (year-completed uint))
  (let
    (
      (provider-id tx-sender)
      (credential-id (var-get credential-counter))
    )
    (var-set credential-counter (+ credential-id u1))
    (ok (map-set education-credentials
      { provider-id: provider-id, credential-id: credential-id }
      {
        institution: institution,
        degree: degree,
        year-completed: year-completed,
        verified: false,
        verifier: none
      }
    ))
  )
)

;; Verify education credential (would be restricted to authorized verifiers in production)
(define-public (verify-credential
    (provider-id principal)
    (credential-id uint))
  (let ((verifier tx-sender))
    (match (map-get? education-credentials { provider-id: provider-id, credential-id: credential-id })
      credential-data
        (ok (map-set education-credentials
          { provider-id: provider-id, credential-id: credential-id }
          (merge credential-data {
            verified: true,
            verifier: (some verifier)
          })
        ))
      (err ERR_NOT_FOUND)
    )
  )
)

;; Read-only function to get credential details
(define-read-only (get-credential (provider-id principal) (credential-id uint))
  (map-get? education-credentials { provider-id: provider-id, credential-id: credential-id })
)

;; Read-only function to check if a credential is verified
(define-read-only (is-credential-verified (provider-id principal) (credential-id uint))
  (match (map-get? education-credentials { provider-id: provider-id, credential-id: credential-id })
    credential-data (get verified credential-data)
    false
  )
)
