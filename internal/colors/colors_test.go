package colors

import (
	"strings"
	"testing"

	"github.com/fatih/color"
	"github.com/spf13/viper"
)

func TestInitPolicy(t *testing.T) {
	originalNoColor := color.NoColor
	originalTTYCheck := stdoutIsTerminal
	t.Cleanup(func() {
		color.NoColor = originalNoColor
		stdoutIsTerminal = originalTTYCheck
		viper.Set("color", false)
		viper.Set("no-color", false)
	})

	preInit := Bold()
	tests := []struct {
		name       string
		tty        bool
		forceColor bool
		noColor    bool
		want       bool
	}{
		{name: "tty", tty: true, want: true},
		{name: "redirected", want: false},
		{name: "forced", forceColor: true, want: true},
		{name: "disabled", tty: true, noColor: true, want: false},
		{name: "disable wins", tty: true, forceColor: true, noColor: true, want: false},
	}

	for i, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			stdoutIsTerminal = func() bool { return tt.tty }
			viper.Set("color", tt.forceColor)
			viper.Set("no-color", tt.noColor)

			Init()
			if got := Active(); got != tt.want {
				t.Fatalf("Active() = %t, want %t", got, tt.want)
			}

			result := Bold().Sprint("test")
			if got := strings.Contains(result, "\x1b["); got != tt.want {
				t.Fatalf("ANSI output = %t, want %t: %q", got, tt.want, result)
			}
			if i == 0 && !strings.Contains(preInit.Sprint("test"), "\x1b[") {
				t.Fatal("constructor created before Init did not adopt the resolved policy")
			}
		})
	}
}

func TestColorOutput_Enabled(t *testing.T) {
	orig := color.NoColor
	defer func() { color.NoColor = orig }()

	color.NoColor = false

	result := Bold().Sprint("test")
	if !strings.Contains(result, "\x1b[") {
		t.Errorf("expected ANSI codes when colors enabled, got: %q", result)
	}
}

func TestColorOutput_Disabled(t *testing.T) {
	orig := color.NoColor
	defer func() { color.NoColor = orig }()

	color.NoColor = true

	result := Bold().Sprint("test")
	if strings.Contains(result, "\x1b[") {
		t.Errorf("expected no ANSI codes when colors disabled, got: %q", result)
	}
	if result != "test" {
		t.Errorf("expected plain 'test', got: %q", result)
	}
}

func TestStripIfDisabled(t *testing.T) {
	orig := color.NoColor
	t.Cleanup(func() { color.NoColor = orig })

	const styled = "\x1b[31mtest\x1b[0m"

	color.NoColor = false
	if got := StripIfDisabled(styled); got != styled {
		t.Fatalf("StripIfDisabled() with color enabled = %q, want %q", got, styled)
	}

	color.NoColor = true
	if got := StripIfDisabled(styled); got != "test" {
		t.Fatalf("StripIfDisabled() with color disabled = %q, want %q", got, "test")
	}
}

func TestAllConstructors(t *testing.T) {
	orig := color.NoColor
	defer func() { color.NoColor = orig }()

	color.NoColor = false

	// Just verify they don't panic and return non-nil
	constructors := []struct {
		name string
		fn   func() *color.Color
	}{
		{"Bold", Bold},
		{"Faint", Faint},
		{"Italic", Italic},
		{"Red", Red},
		{"Green", Green},
		{"Yellow", Yellow},
		{"Blue", Blue},
		{"Magenta", Magenta},
		{"Cyan", Cyan},
		{"White", White},
		{"HiRed", HiRed},
		{"HiGreen", HiGreen},
		{"HiYellow", HiYellow},
		{"HiBlue", HiBlue},
		{"HiMagenta", HiMagenta},
		{"HiCyan", HiCyan},
		{"HiWhite", HiWhite},
		{"BoldRed", BoldRed},
		{"BoldGreen", BoldGreen},
		{"BoldYellow", BoldYellow},
		{"BoldBlue", BoldBlue},
		{"BoldMagenta", BoldMagenta},
		{"BoldCyan", BoldCyan},
		{"BoldWhite", BoldWhite},
		{"BoldHiRed", BoldHiRed},
		{"BoldHiGreen", BoldHiGreen},
		{"BoldHiYellow", BoldHiYellow},
		{"BoldHiBlue", BoldHiBlue},
		{"BoldHiMagenta", BoldHiMagenta},
		{"BoldHiCyan", BoldHiCyan},
		{"BoldHiWhite", BoldHiWhite},
		{"FaintRed", FaintRed},
		{"FaintGreen", FaintGreen},
		{"FaintYellow", FaintYellow},
		{"FaintBlue", FaintBlue},
		{"FaintMagenta", FaintMagenta},
		{"FaintCyan", FaintCyan},
		{"FaintWhite", FaintWhite},
		{"FaintHiRed", FaintHiRed},
		{"FaintHiGreen", FaintHiGreen},
		{"FaintHiYellow", FaintHiYellow},
		{"FaintHiBlue", FaintHiBlue},
		{"FaintHiMagenta", FaintHiMagenta},
		{"FaintHiCyan", FaintHiCyan},
		{"FaintHiWhite", FaintHiWhite},
		{"ItalicFaint", ItalicFaint},
		{"ItalicFaintWhite", ItalicFaintWhite},
		{"ItalicBoldHiYellow", ItalicBoldHiYellow},
		{"BoldBlackOnHiWhite", BoldBlackOnHiWhite},
		{"BoldOnHiYellow", BoldOnHiYellow},
	}

	for _, tc := range constructors {
		t.Run(tc.name, func(t *testing.T) {
			c := tc.fn()
			if c == nil {
				t.Errorf("%s() returned nil", tc.name)
				return
			}
			result := c.Sprint("x")
			if result == "" {
				t.Errorf("%s().Sprint() returned empty", tc.name)
			}
		})
	}
}

func TestNew(t *testing.T) {
	orig := color.NoColor
	defer func() { color.NoColor = orig }()

	color.NoColor = false

	c := New(color.Bold, color.FgRed, color.BgWhite)
	if c == nil {
		t.Fatal("New() returned nil")
	}

	result := c.Sprint("test")
	if !strings.Contains(result, "\x1b[") {
		t.Errorf("New() color should produce ANSI codes, got: %q", result)
	}
}
