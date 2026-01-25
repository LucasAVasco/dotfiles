// Package cli contains the command line arguments
package cli

import (
	"fmt"
	"go-template-exec/parser"
	"io"
	"os"
	"strings"
)

// Args contains the command line arguments. Can be parsed with kong
type Args struct {
	Template      string `type:"path" help:"Template content"`
	TemplateFile  string `arg:"" type:"path" help:"Template path"`
	TemplateStdin bool   `type:"bool" help:"Read template from stdin" default:"false"`
	Data          string `type:"path" help:"Data content"`
	DataFile      string `type:"path" help:"Data path"`
	DataStdin     bool   `type:"bool" help:"Read data from stdin" default:"false"`
	DataFormat    string `type:"string" help:"Data format" default:"json"`
}

// ReadTemplateContent reads the template content, Does not execute it
func (a *Args) ReadTemplateContent() (string, error) {
	var template string

	if a.Template != "" {
		template = a.Template
	} else if a.TemplateStdin {
		templateBytes, err := io.ReadAll(os.Stdin)
		if err != nil {
			return "", fmt.Errorf("failed to read stdin: %w", err)
		}

		template = string(templateBytes)
	} else if a.TemplateFile != "" || a.TemplateStdin {
		templateContent, err := os.ReadFile(a.TemplateFile)
		if err != nil {
			return "", fmt.Errorf("failed to read file: %w", err)
		}

		template = string(templateContent)
	} else {
		return "", fmt.Errorf("template path is required if template content is not provided")
	}

	return template, nil
}

// ReadTemplateData reads the template data. Parses it (json or yaml) and returns the result
func (a *Args) ReadTemplateData() (any, error) {
	// Reader for template data
	var reader io.Reader

	if a.Data != "" {
		reader = strings.NewReader(a.Data)
	} else if a.DataFile != "" {
		file, err := os.Open(a.DataFile)
		if err != nil {
			return "", fmt.Errorf("failed to open data file: %w", err)
		}

		defer file.Close()
		reader = file
	} else if a.DataStdin {
		reader = os.Stdin
	} else {
		return nil, nil
	}

	// Decoded data
	var data any

	if reader != nil {
		var err error
		data, err = parser.ReadData(reader, a.DataFormat)
		if err != nil {
			return "", fmt.Errorf("failed to read stdin: %w", err)
		}
	}

	return data, nil
}
