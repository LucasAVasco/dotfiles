package main

import (
	"fmt"
	"go-template-exec/cli"
	"go-template-exec/parser"

	"github.com/alecthomas/kong"
)

func run() error {
	args := cli.Args{}
	kong.Parse(&args)

	// Stdin validation
	if args.TemplateStdin && args.DataStdin {
		return fmt.Errorf("template and data cannot be read from stdin at the same time")
	}

	// Reads template
	template, err := args.ReadTemplateContent()
	if err != nil {
		return fmt.Errorf("failed to read template: %w", err)
	}

	// Reads template data
	data, err := args.ReadTemplateData()
	if err != nil {
		return fmt.Errorf("failed to read template data: %w", err)
	}

	// Parses template and writes to output
	output, err := parser.ParseAndExecuteTemplate(template, data)
	if err != nil {
		return fmt.Errorf("failed to parse template: %w", err)
	}
	fmt.Print(output)
	return nil
}

func main() {
	if err := run(); err != nil {
		panic(err)
	}
}
