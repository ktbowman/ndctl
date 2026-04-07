**Testing CXL Protocol Errors Using AER Injection**

The `aer-inject` tool currently does not support injecting internal errors such as Correctable Internal Errors (CIE) and Uncorrectable Internal Errors (UIE). By default, internal errors are masked according to the PCI specification and are rarely used. However, these internal errors are now leveraged to notify the PCI and CXL subsystems of CXL protocol errors. The attached patches enable support for CE and UCE internal errors in `aer-inject`, allowing you to test CXL RAS functionality.

**Important Caveats:**
- `aer-inject` will only inject AER errors and does not inject CXL RAS-specific errors directly.
- As a result, functions like `cxl_handle_ras()` and `cxl_handle_cor_ras()` will detect a status of 0 and exit early, which hampers testing.
- To work around this, a debug patch must be added (not included) to hardcode the last RAS error status in `cxl_handle_ras()` and `cxl_handle_cor_ras()`. While not ideal, this workaround facilitates testing of the software paths involved. This is addressed below in 'Patch'.

---

### Prerequisites
- `aer-einj` tool from: https://github.com/intel/aer-inject
- Kernel configuration options:
  ```
  CONFIG_ACPI_APEI_EINJ=y
  CONFIG_CXL_RAS=y
  CONFIG_CXL_PCI=y
  CONFIG_PCIEAER_INJECT=y
  ```
  
---

### aer-inject Patch Details
- The patch is located in `./patches` and should be applied to the `aer-inject` repository, based on the master branch (commit `81701cb`). The patch is 0001-aer-inject-Add-internal-error-injection-support.patch.
- The patch adds support for injecting both correctable (CE) and uncorrectable (UCE) internal errors.
- Additionally, you'll need to apply a kernel-side workaround by hardcoding the RAS error status in the relevant handler, as described earlier.

### Kernel patch Details
Below is patch to set the RAS for testing. 'sed' scripts are also included 

#### Kernel Patch to set CXL RAS status for testing
This is a patch to set the CXL protocol RAS. This based on v7.0-rc6 (7aaa8047eafd).
0001-test-cxl-Force-RAS-status-in-cxl_handle_cor_ras-and-.patch

#### Script to set the Kernel's CXL RAS status
##### 1: Correctable Errors (CE)
sed -i '
/void cxl_handle_cor_ras/,/}/ {
	/status = readl(addr);/ {
		i #define CXL_RAS_CORRECTABLE_STATUS_CACHE_ECC 0x1
		a\    status |= CXL_RAS_CORRECTABLE_STATUS_CACHE_ECC;
	}
}' drivers/cxl/core/ras.c

##### 2: Uncorrectable Errors (UCE)
sed -i '
/bool cxl_handle_ras/,/}/ {
	/status = readl(addr);/ {
		i #define CXL_RAS_UNCORRECTABLE_STATUS_CACHE_ECC 0x1
		a\    status |= CXL_RAS_UNCORRECTABLE_STATUS_CACHE_ECC;
	}
}' drivers/cxl/core/ras.c

---

### Testing Procedure
- The provided scripts illustrate how I ran the tests. You’ll need to modify the scripts to use the correct BDFs for your system.
- Alternatively, you can run the tests manually using commands like:

```bash
aer-inject -s ${bdf} examples/correctable.internal
```

and

```bash
aer-inject -s ${bdf} examples/fatal.internal
```

*Ensure you replace `${bdf}` with the appropriate PCI BDF for your device.*

---

