pushd .. | exit 1
go test -v assets_test.go
go test -coverprofile=coverage.out . # ./test/...
go tool cover -html=coverage.out
