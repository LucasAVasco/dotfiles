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
	Template      string `type:"string" help:"Template content"`
	TemplateFile  string `arg:"" optional:"" type:"path" help:"Template path"`
	TemplateStdin bool   `type:"bool" help:"Read template from stdin" default:"false"`
	Data          string `type:"string" help:"Data content"`
	DataFile      string `type:"path" help:"Data path"`
	DataStdin     bool   `type:"bool" help:"Read data from stdin" default:"false"`
	DataFormat    string `type:"string" help:"Data format" default:"yaml"`
}

// validateCommon validates common arguments (between template data and template content)
func (a *Args) validateCommon() error {
	if a.TemplateStdin && a.DataStdin {
		return fmt.Errorf("template and data cannot be read from stdin at the same time")
	}

	return nil
}

// StdinIsRedirected checks if standard input is being redirected (pipe)
func StdinIsRedirected() (bool, error) {
	if info, err := os.Stdin.Stat(); err != nil {
		return false, fmt.Errorf("failed to get standard input status: %w", err)
	} else {
		return info.Mode()&os.ModeNamedPipe != 0, nil
	}
}

// ReadTemplateContent reads the template content, Does not execute it
func (a *Args) ReadTemplateContent() (string, error) {
	// Validation
	if err := a.validateCommon(); err != nil {
		return "", fmt.Errorf("invalid arguments: %w", err)
	}

	templateSources := 0
	if a.Template != "" {
		templateSources++
	}
	if a.TemplateFile != "" {
		templateSources++
	}
	if a.TemplateStdin {
		templateSources++
	}

	if templateSources > 1 {
		return "", fmt.Errorf("template can not be provided by more than one source")
	}

	// Template not parsed
	var template string

	if a.Template != "" {
		template = a.Template
	} else if a.TemplateStdin {
		templateBytes, err := io.ReadAll(os.Stdin)
		if err != nil {
			return "", fmt.Errorf("failed to read stdin: %w", err)
		}

		template = string(templateBytes)
	} else if a.TemplateFile != "" {
		templateContent, err := os.ReadFile(a.TemplateFile)
		if err != nil {
			return "", fmt.Errorf("failed to read file: %w", err)
		}

		template = string(templateContent)
	} else {
		return "", fmt.Errorf("no template source provided")
	}

	return template, nil
}

// ReadTemplateData reads the template data. Parses it (json or yaml) and returns the result
func (a *Args) ReadTemplateData() (any, error) {
	// Validation
	if err := a.validateCommon(); err != nil {
		return "", fmt.Errorf("invalid arguments: %w", err)
	}

	dataSources := 0
	if a.Data != "" {
		dataSources++
	}
	if a.DataFile != "" {
		dataSources++
	}
	if a.DataStdin {
		dataSources++
	}

	if dataSources > 1 {
		return nil, fmt.Errorf("data can not be provided by more than one source")
	}

	// Reader for template data
	var reader io.Reader

	if a.Data != "" {
		reader = strings.NewReader(a.Data)
	} else if a.DataFile != "" {
		file, err := os.Open(a.DataFile)
		if err != nil {
			return nil, fmt.Errorf("failed to open data file: %w", err)
		}

		defer file.Close()
		reader = file
	} else if a.DataStdin {
		reader = os.Stdin
	} else if !a.TemplateStdin { // If no data is provided, try to read from stdin
		isRedirected, err := StdinIsRedirected()
		if err != nil {
			return nil, fmt.Errorf("failed to check if stdin is redirected: %w", err)
		}
		if isRedirected {
			reader = os.Stdin
		}
	} else {
		return nil, nil
	}

	// Decoded data
	var data any

	if reader != nil {
		var err error
		data, err = parser.ReadData(reader, a.DataFormat)
		if err != nil {
			return nil, fmt.Errorf("failed to read stdin: %w", err)
		}
	}

	return data, nil
}
