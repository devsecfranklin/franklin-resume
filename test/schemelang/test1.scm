; 29 Dec 2022

; scheme < test1.scm

(define (fib n)
  ;; Calculate the nth Fibonacci number recursively
  (if (< n 2)
      1                                 ; base case
      (+ (fib (- n 1)) (fib (- n 2)))))

(fib 5)
