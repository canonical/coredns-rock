## Overview
This document provides an analysis of CoreDNS's cryptographic implementation with respect to FIPS 140 compliance requirements.

Note: As of now, pebble is not built in a FIPS-compliant way. This document will be updated once they are.

## Cryptographic Implementation Analysis

## FIPS Compliance Status

CoreDNS uses both standard Go `crypto` and the extended `https://pkg.go.dev/golang.org/x/crypto` modules. To address the FIPS compliance for the standard package, the following steps are required:

1. **Go Toolchain**: Must use the modified [Go toolchain from Microsoft](https://github.com/microsoft/go/blob/microsoft/release-branch.go1.23/eng/doc/fips/README.md) that links against FIPS-validated cryptographic modules.
2. **OpenSSL**: Must link against a FIPS-validated OpenSSL implementation, e.g. from `core22/fips`.
3. **Build Environment**: Must be built on an Ubuntu Pro machine with FIPS updates enabled, see below.

For the extended module, enduring the non-approved algorithms are not executed would suffice.  
