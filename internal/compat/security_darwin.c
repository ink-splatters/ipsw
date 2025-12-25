/*
 * Backward compatible implementation of SecTrustCopyCertificateChain (macOS 12)
 */

#include <TargetConditionals.h>

#if TARGET_OS_OSX

#include <Availability.h>

#if !defined(__MAC_OS_X_VERSION_MAX_ALLOWED) || \
    __MAC_OS_X_VERSION_MAX_ALLOWED < 120000 || \
    defined(IPSW_SECTRUST_COMPAT)

#include <Security/Security.h>
#include <CoreFoundation/CoreFoundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

enum { COMPAT_MAX_CHAIN_LENGTH = 10 };

CFArrayRef SecTrustCopyCertificateChain(SecTrustRef trust) {
    if (trust == NULL) {
        return NULL;
    }

    /*
     * Ensure trust is evaluated and proceed regardless of the evaluation
     * result (as original implementation does).

     * We use 10.14+ SecTrustEvaluateWithError
     * which is idempotent - returns cached result if already evaluated, but
     * still may be slightly less efficient than original which uses private
     * _SecTrustEvaluateIfNecessary, with finer-grained time-based cache validation.
     *
     * Reference disassembly (macOS 26.2 25C56):
     * https://gist.github.com/ink-splatters/af142fd07c686aed0c5cf97f84a619ee
     */

    CFErrorRef error = NULL;
    (void)SecTrustEvaluateWithError(trust, &error);
    if (error != NULL) {
        CFRelease(error);
    }

    CFIndex count = SecTrustGetCertificateCount(trust);
    if (count <= 0 || count > COMPAT_MAX_CHAIN_LENGTH) {
        return NULL;
    }

    const void *certs[COMPAT_MAX_CHAIN_LENGTH];
    CFIndex actualCount = 0;

    for (CFIndex i = 0; i < count; i++) {
        SecCertificateRef cert = SecTrustGetCertificateAtIndex(trust, i);
        if (cert != NULL) {
            certs[actualCount++] = cert;
        }
    }

    return CFArrayCreate(
        kCFAllocatorDefault,
        certs,
        actualCount,
        &kCFTypeArrayCallBacks
    );
}

#pragma clang diagnostic pop

#endif /* SDK version check */
#endif /* TARGET_OS_OSX */