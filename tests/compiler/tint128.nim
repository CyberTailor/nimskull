import compiler/utils/int128

let (a,b) = divMod(Ten,Ten)

doAssert $One == "1"
doAssert $Ten == "10"
doAssert $Zero == "0"
let c = parseDecimalInt128("12345678989876543210123456789")
doAssert $c == "12345678989876543210123456789"

var d : array[39, Int128]
d[0] =  parseDecimalInt128("1")
d[1] =  parseDecimalInt128("10")
d[2] =  parseDecimalInt128("100")
d[3] =  parseDecimalInt128("1000")
d[4] =  parseDecimalInt128("10000")
d[5] =  parseDecimalInt128("100000")
d[6] =  parseDecimalInt128("1000000")
d[7] =  parseDecimalInt128("10000000")
d[8] =  parseDecimalInt128("100000000")
d[9] =  parseDecimalInt128("1000000000")
d[10] = parseDecimalInt128("10000000000")
d[11] = parseDecimalInt128("100000000000")
d[12] = parseDecimalInt128("1000000000000")
d[13] = parseDecimalInt128("10000000000000")
d[14] = parseDecimalInt128("100000000000000")
d[15] = parseDecimalInt128("1000000000000000")
d[16] = parseDecimalInt128("10000000000000000")
d[17] = parseDecimalInt128("100000000000000000")
d[18] = parseDecimalInt128("1000000000000000000")
d[19] = parseDecimalInt128("10000000000000000000")
d[20] = parseDecimalInt128("100000000000000000000")
d[21] = parseDecimalInt128("1000000000000000000000")
d[22] = parseDecimalInt128("10000000000000000000000")
d[23] = parseDecimalInt128("100000000000000000000000")
d[24] = parseDecimalInt128("1000000000000000000000000")
d[25] = parseDecimalInt128("10000000000000000000000000")
d[26] = parseDecimalInt128("100000000000000000000000000")
d[27] = parseDecimalInt128("1000000000000000000000000000")
d[28] = parseDecimalInt128("10000000000000000000000000000")
d[29] = parseDecimalInt128("100000000000000000000000000000")
d[30] = parseDecimalInt128("1000000000000000000000000000000")
d[31] = parseDecimalInt128("10000000000000000000000000000000")
d[32] = parseDecimalInt128("100000000000000000000000000000000")
d[33] = parseDecimalInt128("1000000000000000000000000000000000")
d[34] = parseDecimalInt128("10000000000000000000000000000000000")
d[35] = parseDecimalInt128("100000000000000000000000000000000000")
d[36] = parseDecimalInt128("1000000000000000000000000000000000000")
d[37] = parseDecimalInt128("10000000000000000000000000000000000000")
d[38] = parseDecimalInt128("100000000000000000000000000000000000000")

for i in 0..<d.len:
  for j in 0..<d.len:
    doAssert(cmp(d[i], d[j]) == cmp(i,j))
    if i + j < d.len:
      doAssert d[i] * d[j] == d[i+j]
    if i - j >= 0:
      doAssert d[i] div d[j] == d[i-j]

var sum: Int128

for it in d:
  sum += it

doAssert $sum == "111111111111111111111111111111111111111"

for it in d.mitems:
  it = -it

for i in 0..<d.len:
  for j in 0..<d.len:
    doAssert(cmp(d[i], d[j]) == -cmp(i,j))
    if i + j < d.len:
      doAssert d[i] * d[j] == -d[i+j]
    if i - j >= 0:
      doAssert d[i] div d[j] == -d[i-j]

doAssert $high(Int128) == "170141183460469231731687303715884105727"
doAssert $low(Int128) == "-170141183460469231731687303715884105728"

var ma = 100'i64
var mb = 13

doAssert toInt128(ma) * toInt128(0) == toInt128(0)
doAssert toInt128(-ma) * toInt128(0) == toInt128(0)

# sign correctness
doAssert divMod(toInt128( ma),toInt128( mb)) == (toInt128( ma div  mb), toInt128( ma mod  mb))
doAssert divMod(toInt128(-ma),toInt128( mb)) == (toInt128(-ma div  mb), toInt128(-ma mod  mb))
doAssert divMod(toInt128( ma),toInt128(-mb)) == (toInt128( ma div -mb), toInt128( ma mod -mb))
doAssert divMod(toInt128(-ma),toInt128(-mb)) == (toInt128(-ma div -mb), toInt128(-ma mod -mb))

doAssert divMod(toInt128( mb),toInt128( mb)) == (toInt128( mb div  mb), toInt128( mb mod  mb))
doAssert divMod(toInt128(-mb),toInt128( mb)) == (toInt128(-mb div  mb), toInt128(-mb mod  mb))
doAssert divMod(toInt128( mb),toInt128(-mb)) == (toInt128( mb div -mb), toInt128( mb mod -mb))
doAssert divMod(toInt128(-mb),toInt128(-mb)) == (toInt128(-mb div -mb), toInt128(-mb mod -mb))

doAssert divMod(toInt128( mb),toInt128( ma)) == (toInt128( mb div  ma), toInt128( mb mod  ma))
doAssert divMod(toInt128(-mb),toInt128( ma)) == (toInt128(-mb div  ma), toInt128(-mb mod  ma))
doAssert divMod(toInt128( mb),toInt128(-ma)) == (toInt128( mb div -ma), toInt128( mb mod -ma))
doAssert divMod(toInt128(-mb),toInt128(-ma)) == (toInt128(-mb div -ma), toInt128(-mb mod -ma))

let e = parseDecimalInt128("70997106675279150998592376708984375")

let strArray = [
  # toHex(e shr 0), toHex(e shr 1), toHex(e shr 2), toHex(e shr 3)
  "000dac6d782d266a37300c32591eee37", "0006d636bc1693351b9806192c8f771b", "00036b1b5e0b499a8dcc030c9647bb8d", "0001b58daf05a4cd46e601864b23ddc6",
  "0000dac6d782d266a37300c32591eee3", "00006d636bc1693351b9806192c8f771", "000036b1b5e0b499a8dcc030c9647bb8", "00001b58daf05a4cd46e601864b23ddc",
  "00000dac6d782d266a37300c32591eee", "000006d636bc1693351b9806192c8f77", "0000036b1b5e0b499a8dcc030c9647bb", "000001b58daf05a4cd46e601864b23dd",
  "000000dac6d782d266a37300c32591ee", "0000006d636bc1693351b9806192c8f7", "00000036b1b5e0b499a8dcc030c9647b", "0000001b58daf05a4cd46e601864b23d",
  "0000000dac6d782d266a37300c32591e", "00000006d636bc1693351b9806192c8f", "000000036b1b5e0b499a8dcc030c9647", "00000001b58daf05a4cd46e601864b23",
  "00000000dac6d782d266a37300c32591", "000000006d636bc1693351b9806192c8", "0000000036b1b5e0b499a8dcc030c964", "000000001b58daf05a4cd46e601864b2",
  "000000000dac6d782d266a37300c3259", "0000000006d636bc1693351b9806192c", "00000000036b1b5e0b499a8dcc030c96", "0000000001b58daf05a4cd46e601864b",
  "0000000000dac6d782d266a37300c325", "00000000006d636bc1693351b9806192", "000000000036b1b5e0b499a8dcc030c9", "00000000001b58daf05a4cd46e601864",
  "00000000000dac6d782d266a37300c32", "000000000006d636bc1693351b980619", "0000000000036b1b5e0b499a8dcc030c", "000000000001b58daf05a4cd46e60186",
  "000000000000dac6d782d266a37300c3", "0000000000006d636bc1693351b98061", "00000000000036b1b5e0b499a8dcc030", "0000000000001b58daf05a4cd46e6018",
  "0000000000000dac6d782d266a37300c", "00000000000006d636bc1693351b9806", "000000000000036b1b5e0b499a8dcc03", "00000000000001b58daf05a4cd46e601",
  "00000000000000dac6d782d266a37300", "000000000000006d636bc1693351b980", "0000000000000036b1b5e0b499a8dcc0", "000000000000001b58daf05a4cd46e60",
  "000000000000000dac6d782d266a3730", "0000000000000006d636bc1693351b98", "00000000000000036b1b5e0b499a8dcc", "0000000000000001b58daf05a4cd46e6",
  "0000000000000000dac6d782d266a373", "00000000000000006d636bc1693351b9", "000000000000000036b1b5e0b499a8dc", "00000000000000001b58daf05a4cd46e",
  "00000000000000000dac6d782d266a37", "000000000000000006d636bc1693351b", "0000000000000000036b1b5e0b499a8d", "000000000000000001b58daf05a4cd46",
  "000000000000000000dac6d782d266a3", "0000000000000000006d636bc1693351", "00000000000000000036b1b5e0b499a8", "0000000000000000001b58daf05a4cd4",
  "0000000000000000000dac6d782d266a", "00000000000000000006d636bc169335", "000000000000000000036b1b5e0b499a", "00000000000000000001b58daf05a4cd",
  "00000000000000000000dac6d782d266", "000000000000000000006d636bc16933", "0000000000000000000036b1b5e0b499", "000000000000000000001b58daf05a4c",
  "000000000000000000000dac6d782d26", "0000000000000000000006d636bc1693", "00000000000000000000036b1b5e0b49", "0000000000000000000001b58daf05a4",
  "0000000000000000000000dac6d782d2", "00000000000000000000006d636bc169", "000000000000000000000036b1b5e0b4", "00000000000000000000001b58daf05a",
  "00000000000000000000000dac6d782d", "000000000000000000000006d636bc16", "0000000000000000000000036b1b5e0b", "000000000000000000000001b58daf05",
  "000000000000000000000000dac6d782", "0000000000000000000000006d636bc1", "00000000000000000000000036b1b5e0", "0000000000000000000000001b58daf0",
  "0000000000000000000000000dac6d78", "00000000000000000000000006d636bc", "000000000000000000000000036b1b5e", "00000000000000000000000001b58daf",
  "00000000000000000000000000dac6d7", "000000000000000000000000006d636b", "0000000000000000000000000036b1b5", "000000000000000000000000001b58da",
  "000000000000000000000000000dac6d", "0000000000000000000000000006d636", "00000000000000000000000000036b1b", "0000000000000000000000000001b58d",
  "0000000000000000000000000000dac6", "00000000000000000000000000006d63", "000000000000000000000000000036b1", "00000000000000000000000000001b58",
  "00000000000000000000000000000dac", "000000000000000000000000000006d6", "0000000000000000000000000000036b", "000000000000000000000000000001b5",
  "000000000000000000000000000000da", "0000000000000000000000000000006d", "00000000000000000000000000000036", "0000000000000000000000000000001b",
  "0000000000000000000000000000000d", "00000000000000000000000000000006", "00000000000000000000000000000003", "00000000000000000000000000000001",
  "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
  "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
  "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000", "00000000000000000000000000000000",
]

for i in 0 ..< 128:
  let str1 = toHex(e shr i)
  let str2 = strArray[i]
  doAssert str1 == str2

let strArray2 = [
  "000dac6d782d266a37300c32591eee37", "001b58daf05a4cd46e601864b23ddc6e", "0036b1b5e0b499a8dcc030c9647bb8dc", "006d636bc1693351b9806192c8f771b8",
  "00dac6d782d266a37300c32591eee370", "01b58daf05a4cd46e601864b23ddc6e0", "036b1b5e0b499a8dcc030c9647bb8dc0", "06d636bc1693351b9806192c8f771b80",
  "0dac6d782d266a37300c32591eee3700", "1b58daf05a4cd46e601864b23ddc6e00", "36b1b5e0b499a8dcc030c9647bb8dc00", "6d636bc1693351b9806192c8f771b800",
  "dac6d782d266a37300c32591eee37000", "b58daf05a4cd46e601864b23ddc6e000", "6b1b5e0b499a8dcc030c9647bb8dc000", "d636bc1693351b9806192c8f771b8000",
  "ac6d782d266a37300c32591eee370000", "58daf05a4cd46e601864b23ddc6e0000", "b1b5e0b499a8dcc030c9647bb8dc0000", "636bc1693351b9806192c8f771b80000",
  "c6d782d266a37300c32591eee3700000", "8daf05a4cd46e601864b23ddc6e00000", "1b5e0b499a8dcc030c9647bb8dc00000", "36bc1693351b9806192c8f771b800000",
  "6d782d266a37300c32591eee37000000", "daf05a4cd46e601864b23ddc6e000000", "b5e0b499a8dcc030c9647bb8dc000000", "6bc1693351b9806192c8f771b8000000",
  "d782d266a37300c32591eee370000000", "af05a4cd46e601864b23ddc6e0000000", "5e0b499a8dcc030c9647bb8dc0000000", "bc1693351b9806192c8f771b80000000",
  "782d266a37300c32591eee3700000000", "f05a4cd46e601864b23ddc6e00000000", "e0b499a8dcc030c9647bb8dc00000000", "c1693351b9806192c8f771b800000000",
  "82d266a37300c32591eee37000000000", "05a4cd46e601864b23ddc6e000000000", "0b499a8dcc030c9647bb8dc000000000", "1693351b9806192c8f771b8000000000",
  "2d266a37300c32591eee370000000000", "5a4cd46e601864b23ddc6e0000000000", "b499a8dcc030c9647bb8dc0000000000", "693351b9806192c8f771b80000000000",
  "d266a37300c32591eee3700000000000", "a4cd46e601864b23ddc6e00000000000", "499a8dcc030c9647bb8dc00000000000", "93351b9806192c8f771b800000000000",
  "266a37300c32591eee37000000000000", "4cd46e601864b23ddc6e000000000000", "99a8dcc030c9647bb8dc000000000000", "3351b9806192c8f771b8000000000000",
  "66a37300c32591eee370000000000000", "cd46e601864b23ddc6e0000000000000", "9a8dcc030c9647bb8dc0000000000000", "351b9806192c8f771b80000000000000",
  "6a37300c32591eee3700000000000000", "d46e601864b23ddc6e00000000000000", "a8dcc030c9647bb8dc00000000000000", "51b9806192c8f771b800000000000000",
  "a37300c32591eee37000000000000000", "46e601864b23ddc6e000000000000000", "8dcc030c9647bb8dc000000000000000", "1b9806192c8f771b8000000000000000",
  "37300c32591eee370000000000000000", "6e601864b23ddc6e0000000000000000", "dcc030c9647bb8dc0000000000000000", "b9806192c8f771b80000000000000000",
  "7300c32591eee3700000000000000000", "e601864b23ddc6e00000000000000000", "cc030c9647bb8dc00000000000000000", "9806192c8f771b800000000000000000",
  "300c32591eee37000000000000000000", "601864b23ddc6e000000000000000000", "c030c9647bb8dc000000000000000000", "806192c8f771b8000000000000000000",
  "00c32591eee370000000000000000000", "01864b23ddc6e0000000000000000000", "030c9647bb8dc0000000000000000000", "06192c8f771b80000000000000000000",
  "0c32591eee3700000000000000000000", "1864b23ddc6e00000000000000000000", "30c9647bb8dc00000000000000000000", "6192c8f771b800000000000000000000",
  "c32591eee37000000000000000000000", "864b23ddc6e000000000000000000000", "0c9647bb8dc000000000000000000000", "192c8f771b8000000000000000000000",
  "32591eee370000000000000000000000", "64b23ddc6e0000000000000000000000", "c9647bb8dc0000000000000000000000", "92c8f771b80000000000000000000000",
  "2591eee3700000000000000000000000", "4b23ddc6e00000000000000000000000", "9647bb8dc00000000000000000000000", "2c8f771b800000000000000000000000",
  "591eee37000000000000000000000000", "b23ddc6e000000000000000000000000", "647bb8dc000000000000000000000000", "c8f771b8000000000000000000000000",
  "91eee370000000000000000000000000", "23ddc6e0000000000000000000000000", "47bb8dc0000000000000000000000000", "8f771b80000000000000000000000000",
  "1eee3700000000000000000000000000", "3ddc6e00000000000000000000000000", "7bb8dc00000000000000000000000000", "f771b800000000000000000000000000",
  "eee37000000000000000000000000000", "ddc6e000000000000000000000000000", "bb8dc000000000000000000000000000", "771b8000000000000000000000000000",
  "ee370000000000000000000000000000", "dc6e0000000000000000000000000000", "b8dc0000000000000000000000000000", "71b80000000000000000000000000000",
  "e3700000000000000000000000000000", "c6e00000000000000000000000000000", "8dc00000000000000000000000000000", "1b800000000000000000000000000000",
  "37000000000000000000000000000000", "6e000000000000000000000000000000", "dc000000000000000000000000000000", "b8000000000000000000000000000000",
  "70000000000000000000000000000000", "e0000000000000000000000000000000", "c0000000000000000000000000000000", "80000000000000000000000000000000",
]

for i in 0 ..< 128:
  let str1 = toHex(e shl i)
  let str2 = strArray2[i]
  doAssert str1 == str2

doAssert toInt128(Inf) == int128.Max
doAssert toInt128(-Inf) == int128.Min
doAssert toInt128(NaN) == int128.Zero
doAssert toInt128(0.0) == int128.Zero
doAssert toInt128(1e100) == int128.Max
doAssert toInt128(-1e100) == int128.Min

doAssert inInt128Range(Inf) == false
doAssert inInt128Range(-Inf) == false
doAssert inInt128Range(NaN) == false
doAssert inInt128Range(0.0) == true
doAssert inInt128Range(1e100) == false
doAssert inInt128Range(-1e100) == false

from math import pow

proc nextafter(`from`,to: float64): float64 {.importc: "nextafter", header: "<math.h>".}

let minValue = -pow(2'f64, 127)
let maxValue = pow(2'f64, 127)

let nonMinValue = nextafter(minValue, Inf)
let lowerThanMinValue = nextafter(minValue, -Inf)

proc testInt128RoundTrip(arg: float64) =
  let int128Val = toInt128(arg)
  let convertedBack = toFloat64(int128Val)
  doAssert(arg == convertedBack)

testInt128RoundTrip(minValue)
# max value is exclusive, out of bounds. It doesn't need to be roundtrip safe
testInt128RoundTrip(nextafter(maxValue, -Inf))
testInt128RoundTrip(nonMinValue)
testInt128RoundTrip(1337'f64)
testInt128RoundTrip(4711'f64)
testInt128RoundTrip(1000000'f64)

doAssert $toInt128(minValue)                  == "-170141183460469231731687303715884105728"
doAssert $toInt128(maxValue)                  ==  "170141183460469231731687303715884105727" # <- last digit different
# test clamping
doAssert $toInt128(nextafter(minValue, -Inf)) == "-170141183460469231731687303715884105728"
doAssert $toInt128(nextafter(maxValue,  Inf)) ==  "170141183460469231731687303715884105727"

doAssert toFloat64(toInt128(NaN)) == 0.0