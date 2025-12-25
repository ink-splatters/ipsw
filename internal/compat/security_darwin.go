//go:build darwin && cgo

// Backward compatibility shim for macOS 12+ Certificate Trust API, used by modern
// go runtime.
//
// Disabled by default for macOS targets newer than 11 (Big Sur).
//
// Set IPSW_SECTRUST_COMPAT to force-enable regardless of the current macOS target.
//

package compat

/*
#cgo CFLAGS: -Wno-deprecated-declarations
#cgo LDFLAGS: -framework Security -framework CoreFoundation
*/
import "C"
