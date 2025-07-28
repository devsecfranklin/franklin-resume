module bitsmasher.net/franklin-resume

go 1.24.4

replace internal/logging => ./internal/logging

require internal/logging v0.0.0-00010101000000-000000000000

require (
	codeberg.org/go-pdf/fpdf v0.11.1 // indirect
	github.com/boombuler/barcode v1.1.0 // indirect
	github.com/phpdave11/gofpdi v1.0.15 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/ruudk/golang-pdf417 v0.0.0-20201230142125-a7e3863a1245 // indirect
	golang.org/x/image v0.29.0 // indirect
)
