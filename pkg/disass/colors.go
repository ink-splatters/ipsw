package disass

import (
	"regexp"

	"github.com/blacktop/ipsw/internal/colors"
)

// disassembly colors
var colorOp = colors.Bold().SprintfFunc()
var colorRegs = colors.BoldHiBlue().SprintFunc()
var colorImm = colors.BoldMagenta().SprintFunc()
var colorAddr = colors.BoldMagenta().SprintfFunc()
var colorOpCodes = colors.FaintHiWhite().SprintFunc()
var colorComment = colors.FaintWhite().SprintFunc()
var colorLocation = colors.HiYellow().SprintfFunc()
var printCurLine = colors.BoldBlackOnHiWhite().PrintfFunc()

var (
	reColorImm      = regexp.MustCompile(`#?-?0x[0-9a-z]+`)
	reColorLocation = regexp.MustCompile(`\sloc_[0-9a-z]+`)
	reColorRegs     = regexp.MustCompile(`\W([wxvbhsdqzp][0-9]{1,2}|(c|s)psr(_c)?|pc|sl|sb|fp|ip|sp|lr|fpsid|fpscr|fpexc)`)
)

func ColorOperands(operands string) string {
	if len(operands) > 0 {
		operands = reColorImm.ReplaceAllStringFunc(operands, func(s string) string {
			return colorImm(s)
		})
		operands = reColorLocation.ReplaceAllStringFunc(operands, func(s string) string {
			return colorLocation(s)
		})
		operands = reColorRegs.ReplaceAllStringFunc(operands, func(s string) string {
			return string(s[0]) + colorRegs(s[1:])
		})
		// TODO: delete this (moved comment coloring into disass module)
		// commentMatch := regexp.MustCompile(`;\s.*$`)
		// operands = commentMatch.ReplaceAllStringFunc(operands, func(s string) string {
		// 	return colorComment(s)
		// })
	}
	return operands
}
