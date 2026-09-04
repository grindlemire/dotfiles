# This makes the capslock key the escape key
if [[ $OSTYPE == 'darwin'* ]]; then
  hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'
fi
