package table

import (
	"strings"
	"testing"

	"github.com/fatih/color"
)

func TestBubbleTableStaticOutputFollowsColorPolicy(t *testing.T) {
	orig := color.NoColor
	t.Cleanup(func() { color.NoColor = orig })

	table := NewBubbleTable([]string{"Name"}, true)
	table.SetData([][]string{{"Example"}})

	color.NoColor = true
	if output := table.RenderStatic(); strings.Contains(output, "\x1b[") {
		t.Fatalf("static table output contains ANSI escapes with color disabled: %q", output)
	}

	color.NoColor = false
	if output := table.RenderStatic(); !strings.Contains(output, "\x1b[") {
		t.Fatalf("static table output contains no ANSI escapes with color enabled: %q", output)
	}
}
