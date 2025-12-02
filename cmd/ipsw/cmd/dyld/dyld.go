/*
Copyright © 2018-2026 blacktop

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package dyld

import (
	"fmt"
	"path/filepath"

	"github.com/blacktop/ipsw/internal/colors"
	"github.com/blacktop/ipsw/pkg/dyld"
	"github.com/spf13/cobra"
)

var symAddrColor = colors.Faint().SprintfFunc()
var symTypeColor = colors.FaintCyan().SprintfFunc()
var symLibColor = colors.FaintMagenta().SprintfFunc()
var symNameColor = colors.Bold().SprintFunc()

var colorAddr = colors.Faint().SprintfFunc()
var colorImage = colors.BoldHiMagenta().SprintFunc()
var colorField = colors.BoldHiBlue().SprintFunc()
var colorClassField = colors.BoldHiMagenta().SprintFunc()

type dscFunc struct {
	Addr  uint64 `json:"addr,omitempty"`
	Start uint64 `json:"start,omitempty"`
	End   uint64 `json:"end,omitempty"`
	Size  uint64 `json:"size,omitempty"`
	Name  string `json:"name,omitempty"`
	Image string `json:"image,omitempty"`
}

type dscFuncImageResolver interface {
	GetImageContainingTextAddr(uint64) (*dyld.CacheImage, error)
	GetImageContainingVMAddr(uint64) (*dyld.CacheImage, error)
	Image(string) (*dyld.CacheImage, error)
}

func resolveDscFuncImage(f dscFuncImageResolver, fn dscFunc) (*dyld.CacheImage, error) {
	if fn.Start != 0 {
		if image, err := f.GetImageContainingTextAddr(fn.Start); err == nil && image != nil {
			return image, nil
		}
		if image, err := f.GetImageContainingVMAddr(fn.Start); err == nil && image != nil {
			return image, nil
		}
	}
	if fn.Image == "" {
		return nil, fmt.Errorf("failed to resolve image for function %#x", fn.Start)
	}

	image, err := f.Image(fn.Image)
	if err != nil {
		return nil, fmt.Errorf("failed to find image %s for function %#x: %w", fn.Image, fn.Start, err)
	}
	if image == nil {
		return nil, fmt.Errorf("failed to find image %s for function %#x", fn.Image, fn.Start)
	}
	return image, nil
}

func getDSCs(path string) []string {
	matches, err := filepath.Glob(filepath.Join(path, "dyld_shared_cache*"))
	if err != nil {
		return nil
	}
	return matches
}

func getImages(dscPath string) []string {
	var images []string
	if f, err := dyld.Open(dscPath); err == nil {
		defer f.Close()
		for _, image := range f.Images {
			images = append(images, filepath.Base(image.Name))
		}
	}
	return images
}

// DyldCmd represents the dyld command
var DyldCmd = &cobra.Command{
	Use:     "dyld",
	Aliases: []string{"dsc"},
	Short:   "Parse dyld_shared_cache",
	Args:    cobra.NoArgs,
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
	},
}
