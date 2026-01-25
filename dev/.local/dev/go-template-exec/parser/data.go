package parser

import (
	"encoding/json"
	"fmt"
	"io"

	"go.yaml.in/yaml/v4"
)

// readAsJson reads a json file from a reader
func readAsJson(reader io.Reader) (any, error) {
	var result any

	err := json.NewDecoder(reader).Decode(&result)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal json: %w", err)
	}
	return result, nil
}

// readAsYaml reads a yaml file from a reader
func readAsYaml(reader io.Reader) (any, error) {
	raw, err := io.ReadAll(reader)
	if err != nil {
		return nil, fmt.Errorf("failed to read reader: %w", err)
	}

	var result any
	if err := yaml.Unmarshal(raw, &result); err != nil {
		return nil, fmt.Errorf("failed to unmarshal yaml: %w", err)
	}

	return result, nil
}

// ReadData reads template data from a reader
func ReadData(reader io.Reader, format string) (any, error) {
	switch format {
	case "json":
		result, err := readAsJson(reader)
		if err != nil {
			return nil, fmt.Errorf("failed to read reader as json: %w", err)
		}

		return result, nil

	case "yaml":
		result, err := readAsYaml(reader)
		if err != nil {
			return nil, fmt.Errorf("failed to read reader as yaml: %w", err)
		}

		return result, nil

	default:
		return nil, fmt.Errorf("unknown format: %s", format)
	}
}
