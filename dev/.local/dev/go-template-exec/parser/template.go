package parser

import (
	"fmt"
	"strings"
	"text/template"

	"github.com/LucasAVasco/falcula/sanitizer"
)

// ParseAndExecuteTemplate parses and executes a Go template with the provided data. It sanitizes the template with the Falcula sanitizer
// before executing it
func ParseAndExecuteTemplate(text string, data any) (string, error) {
	text, err := sanitizer.SanitizeTemplate(text, "")
	if err != nil {
		return "", fmt.Errorf("failed to sanitize text: %w", err)
	}

	textTemplate, err := template.New("text").Parse(text)
	if err != nil {
		return "", fmt.Errorf("failed to parse text: %w", err)
	}

	var builder strings.Builder
	if err := textTemplate.Execute(&builder, data); err != nil {
		return "", fmt.Errorf("failed to execute template: %w", err)
	}

	return builder.String(), nil
}
