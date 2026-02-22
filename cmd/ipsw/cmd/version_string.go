package cmd

import (
	"slices"
	"strings"
)

func ipswVersionString() string {
	return strings.Join(slices.Collect(func(yield func(string) bool) {
		for _, c := range [...]struct{ name, value string }{
			{"Version", AppVersion},
			{"BuildCommit", AppBuildCommit},
		} {
			if v := strings.TrimSpace(c.value); v != "" && !yield(c.name+": "+v) {
				return
			}
		}
	}), ", ")
}
