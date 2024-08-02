package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"slices"
	"strconv"
	"strings"
)

type WeatherStation struct {
	count int64
	min   int64
	max   int64
	sum   int64
}

func main() {
	if len(os.Args) != 2 {
		panic("usage: go run main.go <data_file>")
	}

	dataFile := os.Args[1]
	readFile(dataFile)
}

func readFile(dataFilePath string) {
	file, err := os.Open(dataFilePath)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	parsed := parse(file)
	toStdOut(parsed)
}

func roundLikeJava(x float64) float64 {
	x10 := x * 10.0
	i := math.Trunc(x10)

	if x10 < 0 && i-x10 == 0.5 {
	} else if math.Abs(x10-i) >= 0.5 {
		i += math.Copysign(1, x10)
	}

	if i == 0 {
		return 0
	}
	return i / 10.0
}

func toStdOut(parsed map[string]WeatherStation) {
	// Sort
	keyArr := make([]string, 0, len(parsed))
	for k := range parsed {
		keyArr = append(keyArr, k)
	}

	slices.Sort(keyArr)

	// Make stdOut
	stdOut := "{"
	for _, key := range keyArr {
		val := parsed[key]
		mean := roundLikeJava(float64(val.sum) / 10.0 / float64(val.count))
		stdOut += fmt.Sprintf("%s=%.1f/%.1f/%.1f, ", key, roundLikeJava(float64(val.min)/10.0), mean, roundLikeJava(float64(val.max)/10.0))
	}
	stdOut = strings.TrimSuffix(stdOut, ", ") + "}"
	fmt.Println(stdOut)
}

func parse(file *os.File) map[string]WeatherStation {
	final := make(map[string]WeatherStation, 5)
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		split := strings.Split(scanner.Text(), ";")

		tempFloat, err := strconv.ParseFloat(split[1], 64)
		if err != nil {
			panic(err)
		}
		temp := int64(tempFloat * 10)

		curr, ok := final[split[0]]
		if !ok {
			final[split[0]] = WeatherStation{1, temp, temp, temp}
		} else {
			curr.count += 1
			curr.sum += temp

			if curr.min > temp {
				curr.min = temp
			}

			if curr.max < temp {
				curr.max = temp
			}

			final[split[0]] = curr
		}
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}

	return final
}
