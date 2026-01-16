# CoreDNS FIPS Compliance

For comprehensive information about FIPS 140-3 compliance in Canonical Kubernetes, including how ROCKs are built with FIPS support, please refer to the [k8s-snap FIPS documentation](https://github.com/canonical/k8s-snap/blob/main/docs/dev/fips.md).

> **Note:** As of now, pebble is not built in a FIPS-compliant way. This document will be updated once it is.

## CoreDNS-Specific Information

CoreDNS uses both standard Go `crypto` and the extended `golang.org/x/crypto` modules. For the extended module, ensuring that non-approved algorithms are not executed would suffice for FIPS compliance.

CoreDNS's cryptographic usage includes:

- **DNS-over-TLS (DoT)**: Secure DNS queries using TLS
- **DNS-over-HTTPS (DoH)**: Secure DNS queries over HTTPS
- **Backend Communication**: Secure communication with backend services using TLS
