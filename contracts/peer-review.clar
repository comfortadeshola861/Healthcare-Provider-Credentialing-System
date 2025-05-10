;; Peer Review Contract
;; Manages quality assessment by colleagues

;; Data structures
(define-map peer-reviews
  { provider-id: principal, review-id: uint }
  {
    reviewer: principal,
    rating: uint,  ;; 1-5 scale
    comments: (string-utf8 500),
    review-date: uint,
    category: (string-utf8 100)
  }
)

(define-data-var review-counter uint u0)

;; Error codes
(define-constant ERR_UNAUTHORIZED u1)
(define-constant ERR_NOT_FOUND u3)
(define-constant ERR_INVALID_RATING u4)

;; Submit a peer review
(define-public (submit-review
    (provider-id principal)
    (rating uint)
    (comments (string-utf8 500))
    (category (string-utf8 100)))
  (let
    (
      (reviewer tx-sender)
      (review-id (var-get review-counter))
    )
    (if (or (< rating u1) (> rating u5))
      (err ERR_INVALID_RATING)
      (begin
        (var-set review-counter (+ review-id u1))
        (ok (map-set peer-reviews
          { provider-id: provider-id, review-id: review-id }
          {
            reviewer: reviewer,
            rating: rating,
            comments: comments,
            review-date: block-height,
            category: category
          }
        ))
      )
    )
  )
)

;; Read-only function to get review details
(define-read-only (get-review (provider-id principal) (review-id uint))
  (map-get? peer-reviews { provider-id: provider-id, review-id: review-id })
)

;; Read-only function to get average rating for a provider
;; Note: In a real implementation, this would need to be calculated off-chain
;; or through a more complex mechanism as Clarity doesn't support loops
(define-read-only (get-provider-rating (provider-id principal))
  ;; Placeholder - in a real implementation, this would aggregate ratings
  u0
)
