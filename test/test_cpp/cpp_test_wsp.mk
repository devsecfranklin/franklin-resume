.PHONY: clean All

All:
	@echo ----------Building project:[ cpp_test_codelite - Debug ]----------
	@"$(MAKE)" -f "cpp_test_codelite.mk"
clean:
	@echo ----------Cleaning project:[ cpp_test_codelite - Debug ]----------
	@"$(MAKE)" -f "cpp_test_codelite.mk" clean
