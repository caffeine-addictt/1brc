package main

import (
	"os"
	"testing"
)

func BenchmarkProcess(b *testing.B) {
	data, err := os.Open("./measurements.txt")
	if err != nil {
		b.Fatal(err)
	}
	defer data.Close()

	measurements := parse(data)
	rows := int64(0)
	for _, m := range measurements {
		rows += m.count
	}

	b.ReportAllocs()
	b.ResetTimer()
	b.ReportMetric(float64(rows), "rows/op")

	for i := 0; i < b.N; i++ {
		parse(data)
	}
}
