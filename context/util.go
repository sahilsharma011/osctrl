package context

import (
	"crypto/rand"
	"encoding/base64"
	"io/ioutil"

	"github.com/segmentio/ksuid"
)

// Helper to generate a random string of n characters
func generateRandomString(n int) string {
	b := make([]byte, n)
	_, err := rand.Read(b)
	// Note that err == nil only if we read len(b) bytes.
	if err != nil {
		return errorRandomString
	}
	return base64.URLEncoding.EncodeToString(b)
}

// Helper to generate a KSUID
// See https://github.com/segmentio/ksuid for more info about KSUIDs
func generateKSUID() string {
	id := ksuid.New()
	return id.String()
}

// ReadExternalFile to read an external file and return contents
func ReadExternalFile(path string) string {
	content, err := ioutil.ReadFile(path)
	if err != nil {
		return ""
	}
	return string(content)
}