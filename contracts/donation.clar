(define-constant LISTING_NOT_FOUND u404)

(define-data-var totalListing int 0)
;; principal => {}
(define-map ListingData principal 
                        { neededAmount: uint,  
                          description: (string-ascii 100), 
                          contact: (string-ascii 100),
                          receivedAmount: uint
                        } )

(define-public (list-needed (needer principal) (needAmount uint)
                            (description (string-ascii 100))
                            (contact (string-ascii 100)))
  (begin
    (print needer) 
    (print needAmount) 
    (print description) 
    (print contact) 
    (map-insert ListingData needer {neededAmount: needAmount, receivedAmount: u0, description: description, contact: contact})
    (var-set totalListing (+ 1 (var-get totalListing)))
    (ok needer)
  )
)

(define-read-only (get-listing (needer principal)) 
  (begin 
    (map-get? ListingData needer)
  )
)

(define-public (donate-stx (needer principal) (amount uint)) 
  (let
    (
      (listing (unwrap! (map-get? ListingData needer) (err LISTING_NOT_FOUND)))
      (neededAmountValue (get neededAmount listing))
      (contactValue (get contact listing))
      (descriptionValue (get description listing))
      (currentReceivedAmount (get receivedAmount listing))
    )

    (asserts! (not (is-eq tx-sender needer)) (err u400))
    (print contactValue)

    (try! (stx-transfer? neededAmountValue tx-sender needer))
    (map-set ListingData needer (merge
        listing { receivedAmount: (+  amount currentReceivedAmount)}
    ))
    ;; (map-set ListingData needer {
    ;;     neededAmount: neededAmountValue, receivedAmount: (+  amount currentReceivedAmount) , contact: contactValue, description: descriptionValue
    ;; })
    (ok neededAmountValue)
  )
)

(define-read-only (get-total-listing)
   (var-get totalListing)
)

(define-public (say-hello)
  (ok "Say Hello" )
)
