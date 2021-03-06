package beepbox.synth;

/*
Copyright (C) 2012 John Nesky

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

// { region IMPORTS **COMPLETE** 

using StringTools;

// } endregion

class Song
{

	// { region VARIABLES **COMPLETE**

	static var oldestVersion:Int = 2;
	static var latestVersion:Int = 5;
	static var base64IntToChar: Array<String> = [
		"0", "1", "2", "3", "4", "5", "6", "7",
		"8", "9", "a", "b", "c", "d", "e", "f",
		"g", "h", "i", "j", "k", "l", "m", "n",
		"o", "p", "q", "r", "s", "t", "u", "v",
		"w", "x", "y", "z", "A", "B", "C", "D",
		"E", "F", "G", "H", "I", "J", "K", "L",
		"M", "N", "O", "P", "Q", "R", "S", "T",
		"U", "V", "W", "X", "Y", "Z", "-", "_"
	];
	static var base64CharToInt:Map<String,Int> = [
		'0'=>0, '1'=>1, '2'=>2, '3'=>3, '4'=>4, '5'=>5, '6'=>6, '7'=>7,
		'8'=>8, '9'=>9, 'a'=>10, 'b'=>11, 'c'=>12, 'd'=>13, 'e'=>14, 'f'=>15,
		'g'=>16, 'h'=>17, 'i'=>18, 'j'=>19, 'k'=>20, 'l'=>21, 'm'=>22, 'n'=>23,
		'o'=>24, 'p'=>25, 'q'=>26, 'r'=>27, 's'=>28, 't'=>29, 'u'=>30, 'v'=>31,
		'w'=>32, 'x'=>33, 'y'=>34, 'z'=>35, 'A'=>36, 'B'=>37, 'C'=>38, 'D'=>39,
		'E'=>40, 'F'=>41, 'G'=>42, 'H'=>43, 'I'=>44, 'J'=>45, 'K'=>46, 'L'=>47,
		'M'=>48, 'N'=>49, 'O'=>50, 'P'=>51, 'Q'=>52, 'R'=>53, 'S'=>54, 'T'=>55,
		'U'=>56, 'V'=>57, 'W'=>58, 'X'=>59, 'Y'=>60, 'Z'=>61, '-'=>62, '_'=>63
	];

	public var scale:Int;
	public var key:Int;
	public var tempo:Int;
	public var reverb:Int;
	public var beats:Int;
	public var bars:Int;
	public var patterns:Int;
	public var parts:Int;
	public var instruments:Int;
	public var loopStart:Int;
	public var loopLength:Int;
	public var channelPatterns:Array<Array<BarPattern>>;
	public var channelBars:Array<Array<Int>>;
	public var channelOctaves:Array<Int>;
	public var instrumentWaves:Array<Array<Int>>;
	public var instrumentFilters:Array<Array<Int>>;
	public var instrumentAttacks:Array<Array<Int>>;
	public var instrumentEffects:Array<Array<Int>>;
	public var instrumentChorus:Array<Array<Int>>;
	public var instrumentVolumes:Array<Array<Int>>;
	
	// } endregion

	// { region INITIALIZE **COMPLETE**
	
	public function new(?string:String)
	{
		if (string != null) fromString(string);
		else initToDefault();
	}

	public function initToDefault()
	{
		channelPatterns = [
			[new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern()], 
			[new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern()], 
			[new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern()], 
			[new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern(), new BarPattern()], 
		];
		channelBars = [
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		];
		channelOctaves = [3, 2, 1, 0];
		instrumentVolumes = [[0], [0], [0], [0]];
		instrumentWaves   = [[1], [1], [1], [1]];
		instrumentFilters = [[0], [0], [0], [0]];
		instrumentAttacks = [[1], [1], [1], [1]];
		instrumentEffects = [[0], [0], [0], [0]];
		instrumentChorus  = [[0], [0], [0], [0]];
		scale = 0;
		key = Music.keyNames.length - 1;
		loopStart = 0;
		loopLength = 4;
		tempo = 7;
		reverb = 0;
		beats = 8;
		bars = 16;
		patterns = 8;
		parts = 4;
		instruments = 1;
	}

	// } endregion

	// { region FROM STRING
	
	public function fromString(compressed:String)
	{
		if (compressed == null || compressed.length == 0) {
			initToDefault();
			return;
		}

		compressed = StringTools.trim(compressed);

		if (compressed.charAt(0) == "#") compressed = compressed.substr(1);
		if (compressed.charAt(0) == "{") {
			// TODO: fromJsonObject(JSON.parse(compressed));
			return;
		}

		initToDefault();

		var charIndex:Int = 0;
		var base64CharToInt:Map<String, Int> = Song.base64CharToInt; // beforeThree ? oldBase64 : newBase64;

		var version:Int = Song.base64CharToInt[compressed.charAt(charIndex++)];
		if (version == -1 || version > latestVersion || version < oldestVersion) return;
		var beforeThree = version < 3;
		var beforeFour = version < 4;
		var beforeFive = version < 5;
		if (beforeThree) instrumentAttacks = [[0],[0],[0],[0]];
		if (beforeThree) instrumentWaves   = [[1],[1],[1],[0]];

		while (charIndex < compressed.length)
		{
			var command:String = compressed.charAt(charIndex++);
			var bits:BitFieldReader;
			var channel:Int;

			if (command == 's') 
			{ 
				scale = base64CharToInt[compressed.charAt(charIndex++)];
				if (beforeThree && scale == 10) scale = 11;
			}
			else if (command == 'k') 
			{
				key = base64CharToInt[compressed.charAt(charIndex++)];
			}
			else if (command == 'l') 
			{
				if (beforeFive) loopStart = base64CharToInt[compressed.charAt(charIndex++)];
				else loopStart = (base64CharToInt[compressed.charAt(charIndex++)] << 6) + base64CharToInt[compressed.charAt(charIndex++)];
			}
			else if (command == 'e') 
			{
				if (beforeFive) loopLength = base64CharToInt[compressed.charAt(charIndex++)];
				else loopLength = (base64CharToInt[compressed.charAt(charIndex++)] << 6) + base64CharToInt[compressed.charAt(charIndex++)] + 1;
			}
			else if (command == 't') 
			{
				if (beforeFour) tempo = [1, 4, 7, 10][base64CharToInt[compressed.charAt(charIndex++)]];
				else tempo = base64CharToInt[compressed.charAt(charIndex++)];
				tempo = clip(0, Music.tempoNames.length, tempo);
			}
			else if (command == 'm') 
			{
				reverb = base64CharToInt[compressed.charAt(charIndex++)];
				reverb = clip(0, Music.reverbRange, reverb);
			}
			else if (command == 'a') 
			{
				if (beforeThree) beats = [6, 7, 8, 9, 10][base64CharToInt[compressed.charAt(charIndex++)]];
				else beats = base64CharToInt[compressed.charAt(charIndex++)] + 1;
				beats = Math.floor(Math.max(Music.beatsMin, Math.min(Music.beatsMax, beats)));
			}
			else if (command == 'g') 
			{
				bars = (base64CharToInt[compressed.charAt(charIndex++)] << 6) + base64CharToInt[compressed.charAt(charIndex++)] + 1;
				bars = Math.floor(Math.max(Music.barsMin, Math.min(Music.barsMax, bars)));
			}
			else if (command == 'j') 
			{
				patterns = base64CharToInt[compressed.charAt(charIndex++)] + 1;
				patterns = Math.floor(Math.max(Music.patternsMin, Math.min(Music.patternsMax, patterns)));
			}
			else if (command == 'i') 
			{
				instruments = base64CharToInt[compressed.charAt(charIndex++)] + 1;
				instruments = Math.floor(Math.max(Music.instrumentsMin, Math.min(Music.instrumentsMax, instruments)));
			}
			else if (command == 'r') 
			{
				parts = Music.partCounts[base64CharToInt[compressed.charAt(charIndex++)]];
			}
			else if (command == 'w') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					instrumentWaves[channel][0] = clip(0, Music.waveNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
				} 
				else 
				{
					for (channel in 0...Music.numChannels) 
					{
						for (i in 0...instruments) 
						{
							instrumentWaves[channel][i] = clip(0, Music.waveNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
						}
					}
				}
			}
			else if (command == 'f') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					instrumentFilters[channel][0] = [0, 2, 3, 5][clip(0, Music.filterNames.length, base64CharToInt[compressed.charAt(charIndex++)])];
				} 
				else
				{
					for (channel in 0...Music.numChannels)
					{
						for (i in 0...instruments)
						{
							instrumentFilters[channel][i] = clip(0, Music.filterNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
						}
					}
				}
			}
			else if (command == 'd') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					instrumentAttacks[channel][0] = clip(0, Music.attackNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
				}
				else
				{
					for (channel in 0...Music.numChannels)
					{
						for (i in 0...instruments)
						{
							instrumentAttacks[channel][i] = clip(0, Music.attackNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
						}
					}
				}
			}
			else if (command == 'c') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					instrumentEffects[channel][0] = clip(0, Music.effectNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
					if (instrumentEffects[channel][0] == 1) instrumentEffects[channel][0] = 3;
					else if (instrumentEffects[channel][0] == 3) instrumentEffects[channel][0] = 5;
				} 
				else {
					for (channel in 0...Music.numChannels)
					{
						for (i in 0...instruments)
						{
							instrumentEffects[channel][i] = clip(0, Music.effectNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
						}
					}
				}
			}
			else if (command == 'h') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					instrumentChorus[channel][0] = clip(0, Music.chorusNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
				}
				else
				{
					for (channel in 0...Music.numChannels)
					{
						for (i in 0...instruments)
						{
							instrumentChorus[channel][i] = clip(0, Music.chorusNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
						}
					}
				}
			}
			else if (command == 'v') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					instrumentVolumes[channel][0] = clip(0, Music.volumeNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
				}
				else
				{
					for (channel in 0...Music.numChannels)
					{
						for (i in 0...instruments)
						{
							instrumentVolumes[channel][i] = clip(0, Music.volumeNames.length, base64CharToInt[compressed.charAt(charIndex++)]);
						}
					}
				}
			}
			else if (command == 'o') 
			{
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					channelOctaves[channel] = clip(0, 5, base64CharToInt[compressed.charAt(charIndex++)]);
				}
				else
				{
					for (channel in 0...Music.numChannels)
					{
						channelOctaves[channel] = clip(0, 5, base64CharToInt[compressed.charAt(charIndex++)]);
					}
				}
			}
			else if (command == 'b') 
			{
				var subStringLength:Int = 0;
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					var barCount:Int = base64CharToInt[compressed.charAt(charIndex++)];
					subStringLength = Math.ceil(barCount * 0.5);
					bits = new BitFieldReader(base64CharToInt, compressed.substr(charIndex, subStringLength));
					for (i in 0...barCount) channelBars[channel][i] = bits.read(3) + 1;
				}
				else if (beforeFive)
				{
					var neededBits:Int = 0;
					while ((1 << neededBits) < patterns) neededBits++;
					subStringLength = Math.ceil(Music.numChannels * bars * neededBits / 6.0);
					bits = new BitFieldReader(base64CharToInt, compressed.substr(charIndex, subStringLength));
					for (channel in 0...Music.numChannels)
					{
						// ARRAY LENGTH: channelBars[channel].length = bars;
						for (i in 0...bars)
						{
							channelBars[channel][i] = bits.read(neededBits);
						}
					}
				}
				charIndex += subStringLength;
			}
			else if (command == 'p') 
			{
				var bitStringLength:Int = 0;
				if (beforeThree)
				{
					channel = base64CharToInt[compressed.charAt(charIndex++)];
					//var patternCount:Int = base64CharToInt[compressed.charAt(charIndex++)];
					
					bitStringLength = base64CharToInt[compressed.charAt(charIndex++)];
					bitStringLength = bitStringLength << 6;
					bitStringLength += base64CharToInt[compressed.charAt(charIndex++)];
				}
				else
				{
					channel = 0;
					var bitStringLengthLength:Int = base64CharToInt[compressed.charAt(charIndex++)];
					while (bitStringLengthLength > 0) {
						bitStringLength = bitStringLength << 6;
						bitStringLength += base64CharToInt[compressed.charAt(charIndex++)];
						bitStringLengthLength--;
					}
				}
				
				bits = new BitFieldReader(base64CharToInt, compressed.substr(charIndex, bitStringLength));
				charIndex += bitStringLength;
				
				var neededInstrumentBits:Int = 0;
				while ((1 << neededInstrumentBits) < instruments) neededInstrumentBits++;
				while (true) {
					channelPatterns[channel] = [];
					
					var octaveOffset:Int = channel == 3 ? 0 : channelOctaves[channel] * 12;
					var note:Note = null;
					var pin:NotePin = null;
					var lastPitch:Int = (channel == 3 ? 4 : 12) + octaveOffset;
					var recentPitches:Array<Int> = channel == 3 ? [4,6,7,2,3,8,0,10] : [12, 19, 24, 31, 36, 7, 0];
					var recentShapes:Array<Dynamic> = [];
					for (i in 0...recentPitches.length) recentPitches[i] += octaveOffset;
					
					for (i in 0...patterns) {
						var newPattern: BarPattern = new BarPattern();
						newPattern.instrument = bits.read(neededInstrumentBits);
						channelPatterns[channel][i] = newPattern;
						
						if (!beforeThree && bits.read(1) == 0) continue;
						
						var curPart:Int = 0;
						var newNotes:Array<Note> = [];
						while (curPart < beats * parts)
						{
							var useOldShape:Bool = bits.read(1) == 1;
							var newNote:Bool = false;
							var shapeIndex:Int = 0;
							if (useOldShape) shapeIndex = bits.readLongTail(0, 0);
							else newNote = bits.read(1) == 1;
							
							if (!useOldShape && !newNote)
							{
								var restLength:Int = bits.readPartDuration();
								curPart += restLength;
							}
							else
							{
								var shape:Shape;
								var pitch:Int;
								if (useOldShape)
								{
									shape = recentShapes[shapeIndex];
									recentShapes.splice(shapeIndex, 1);
								}
								else
								{
									shape = {
										pitchCount: 1,
										pinCount: bits.readPinCount(),
										initialVolume: bits.read(2),
										pins: [],
										length: 0,
										bendCount: 0
									}
									while (shape.pitchCount < 4 && bits.read(1) == 1) shape.pitchCount++;
									
									for (j in 0...shape.pinCount)
									{
										shape.length += bits.readPartDuration();
										var pinObj:PinObj = {
											pitchBend: bits.read(1) == 1,
											time: shape.length,
											volume:  bits.read(2),
										}
										if (pinObj.pitchBend) shape.bendCount++;
										shape.pins.push(pinObj);
									}
								}
								recentShapes.unshift(shape);
								if (recentShapes.length > 10) recentShapes.pop();
								
								note = new Note(0, curPart, curPart + shape.length, shape.initialVolume);
								note.pitches = [];
								// ARRAY LENGTH: note.pins.length = 1;
								var pitchBends: Array<Int> = [];
								for (j in 0...shape.pitchCount + shape.bendCount)
								{
									var useOldPitch:Bool = bits.read(1) == 1;
									if (!useOldPitch)
									{
										var interval:Int = bits.readPitchInterval();
										pitch = lastPitch;
										var intervalIter:Int = interval;
										while (intervalIter > 0)
										{
											pitch++;
											while (recentPitches.indexOf(pitch) != -1) pitch++;
											intervalIter--;
										}
										while (intervalIter < 0)
										{
											pitch--;
											while (recentPitches.indexOf(pitch) != -1) pitch--;
											intervalIter++;
										}
									}
									else
									{
										var pitchIndex:Int = bits.read(3);
										pitch = recentPitches[pitchIndex];
										recentPitches.splice(pitchIndex, 1);
									}
									
									recentPitches.unshift(pitch);
									if (recentPitches.length > 8) recentPitches.pop();
									
									if (j < shape.pitchCount) note.pitches.push(pitch);
									else pitchBends.push(pitch);
									
									if (j == shape.pitchCount - 1) lastPitch = note.pitches[0];
									else lastPitch = pitch;
								}
								
								pitchBends.unshift(note.pitches[0]);
								
								for (pinObj in shape.pins)
								{
									if (pinObj.pitchBend) pitchBends.shift();
									pin = new NotePin(pitchBends[0] - note.pitches[0], pinObj.time, pinObj.volume);
									note.pins.push(pin);
								}
								curPart = note.end;
								newNotes.push(note);
							}
						}
						newPattern.notes = newNotes;
					} // for (i = 0; i < patterns; i++) {
					
					if (beforeThree) break;
					else
					{
						channel++;
						if (channel >= Music.numChannels) break;
					}
				} // while (true)
			}
		}

	}

	// } endregion

	// { region UTIL **COMPLETE**
	
	function clip(min:Int, max:Int, value:Int):Int
	{
		if (value < max)
		{
			if (value >= min) return value;
			else return min;
		}
		else return max - 1;
	}

	public function getPattern(channel:Int, bar:Int):BarPattern
	{
		var patternIndex = channelBars[channel][bar];
		if (patternIndex == 0) return null;
		return channelPatterns[channel][patternIndex - 1];
	}
	
	public function getPatternInstrument(channel:Int, bar:Int):Int
	{
		var pattern = getPattern(channel, bar);
		return pattern == null ? 0 : pattern.instrument;
	}

	public function getBeatsPerMinute():Int
	{
		return Math.round(120.0 * Math.pow(2.0, (-4.0 + this.tempo) / 9.0));
	}

	// } endregion

	// { region **NOT NEEDED FOR PLAYBACK**

	// { region FROM JSON
	
	/* TODO:
	public function fromJsonObject(jsonObject: Object): void {
		var i: int;
		var k: int;
		var channel: int;
		var channelObject: *;
		
		initToDefault();
		if (!jsonObject) return;
		const version: int = int(jsonObject.version);
		if (version != 5) return;
		
		this.scale = 11; // default to expert.
		if (jsonObject.scale != undefined) {
			const scale: int = Music.scaleNames.indexOf(jsonObject.scale);
			if (scale != -1) this.scale = scale;
		}
		
		if (jsonObject.key != undefined) {
			if (typeof(jsonObject.key) == "number") {
				this.key = Music.keyNames.length - 1 - (uint(jsonObject.key + 1200) % Music.keyNames.length);
			} else if (typeof(jsonObject.key) == "string") {
				const key: String = jsonObject.key;
				const letter: String = key.charAt(0).toUpperCase();
				const symbol: String = key.charAt(1).toLowerCase();
				var index: * = {"C": 11, "D": 9, "E": 7, "F": 6, "G": 4, "A": 2, "B": 0}[letter];
				const offset: * = {"#": -1, "♯": -1, "b": 1, "♭": 1}[symbol];
				if (index != undefined) {
					if (offset != undefined) index += offset;
					if (index < 0) index += 12;
					index = index % 12;
					this.key = index;
				}
			}
		}
		
		if (jsonObject.beatsPerMinute != undefined) {
			const bpm: Number = int(jsonObject.beatsPerMinute);
			this.tempo = Math.round(4.0 + 9.0 * Math.log(bpm / 120.0) / Math.LN2);
			this.tempo = clip(0, Music.tempoNames.length, this.tempo);
		}
		
		if (jsonObject.reverb != undefined) {
			this.reverb = clip(0, Music.reverbRange, int(jsonObject.reverb));
		}
		
		if (jsonObject.beatsPerBar != undefined) {
			this.beats = Math.max(Music.beatsMin, Math.min(Music.beatsMax, int(jsonObject.beatsPerBar)));
		}
		
		if (jsonObject.ticksPerBeat != undefined) {
			this.parts = Math.max(3, Math.min(4, int(jsonObject.ticksPerBeat)));
		}
		
		var maxInstruments: int = 1;
		var maxPatterns: int = 1;
		var maxBars: int = 1;
		for (channel in 0...Music.numChannels
	
	/* TODO:
		public function toString(): String {
		var channel: int;
		var i: int;
		var bits: BitFieldWriter;
		var result: String = "";
		var base64IntToChar: Array = Song.base64IntToChar;
		
		result += base64IntToChar[latestVersion];
		result += "s" + base64IntToChar[scale];
		result += "k" + base64IntToChar[key];
		result += "l" + base64IntToChar[loopStart >> 6] + base64IntToChar[loopStart & 0x3f];
		result += "e" + base64IntToChar[(loopLength - 1) >> 6] + base64IntToChar[(loopLength - 1) & 0x3f];
		result += "t" + base64IntToChar[tempo];
		result += "m" + base64IntToChar[reverb];
		result += "a" + base64IntToChar[beats - 1];
		result += "g" + base64IntToChar[(bars - 1) >> 6] + base64IntToChar[(bars - 1) & 0x3f];
		result += "j" + base64IntToChar[patterns - 1];
		result += "i" + base64IntToChar[instruments - 1];
		result += "r" + base64IntToChar[Music.partCounts.indexOf(parts)];
		
		result += "w";
		for (channel = 0; channel < Music.numChannels; channel++) for (i in 0...instruments) {
			result += base64IntToChar[instrumentWaves[channel][i]];
		}
		
		result += "f";
		for (channel = 0; channel < Music.numChannels; channel++) for (i in 0...instruments) {
			result += base64IntToChar[instrumentFilters[channel][i]];
		}
		
		result += "d";
		for (channel = 0; channel < Music.numChannels; channel++) for (i in 0...instruments) {
			result += base64IntToChar[instrumentAttacks[channel][i]];
		}
		
		result += "c";
		for (channel = 0; channel < Music.numChannels; channel++) for (i in 0...instruments) {
			result += base64IntToChar[instrumentEffects[channel][i]];
		}
		
		result += "h";
		for (channel = 0; channel < Music.numChannels; channel++) for (i in 0...instruments) {
			result += base64IntToChar[instrumentChorus[channel][i]];
		}
		
		result += "v";
		for (channel = 0; channel < Music.numChannels; channel++) for (i in 0...instruments) {
			result += base64IntToChar[instrumentVolumes[channel][i]];
		}
		
		result += "o";
		for (channel = 0; channel < Music.numChannels; channel++) {
			result += base64IntToChar[channelOctaves[channel]];
		}
		
		result += "b";
		bits = new BitFieldWriter();
		var neededBits: int = 0;
		while ((1 << neededBits) < patterns + 1) neededBits++;
		for (channel = 0; channel < Music.numChannels; channel++) for (i = 0; i < bars; i++) {
			bits.write(neededBits, channelBars[channel][i]);
		}
		result += bits.encodeBase64(base64IntToChar);
		
		result += "p";
		bits = new BitFieldWriter();
		var neededInstrumentBits: int = 0;
		while ((1 << neededInstrumentBits) < instruments) neededInstrumentBits++;
		for (channel = 0; channel < Music.numChannels; channel++) {
			var octaveOffset: int = channel == 3 ? 0 : channelOctaves[channel] * 12;
			var lastPitch: int = (channel == 3 ? 4 : 12) + octaveOffset;
			var recentPitches: Array = channel == 3 ? [4,6,7,2,3,8,0,10] : [12, 19, 24, 31, 36, 7, 0];
			var recentShapes: Array = [];
			for (i = 0; i < recentPitches.length; i++) {
				recentPitches[i] += octaveOffset;
			}
			for each (var p: BarPattern in channelPatterns[channel]) {
				bits.write(neededInstrumentBits, p.instrument);
				
				if (p.notes.length > 0) {
					bits.write(1, 1);
					
					var curPart: int = 0;
					for each (var t: Note in p.notes) {
						if (t.start > curPart) {
							bits.write(2, 0); // rest
							bits.writePartDuration(t.start - curPart);
						}
						
						var shapeBits: BitFieldWriter = new BitFieldWriter();
						
						// 0: 1 pitch, 10: 2 pitches, 110: 3 pitches, 111: 4 pitches
						for (i = 1; i < t.pitches.length; i++) shapeBits.write(1,1);
						if (t.pitches.length < 4) shapeBits.write(1,0);
						
						shapeBits.writePinCount(t.pins.length - 1);
						
						shapeBits.write(2, t.pins[0].volume); // volume
						
						var shapePart: int = 0;
						var startPitch: int = t.pitches[0];
						var currentPitch: int = startPitch;
						var pitchBends: Array = [];
						for (i = 1; i < t.pins.length; i++) {
							var pin: NotePin = t.pins[i];
							var nextPitch: int = startPitch + pin.interval;
							if (currentPitch != nextPitch) {
								shapeBits.write(1, 1);
								pitchBends.push(nextPitch);
								currentPitch = nextPitch;
							} else {
								shapeBits.write(1, 0);
							}
							shapeBits.writePartDuration(pin.time - shapePart);
							shapePart = pin.time;
							shapeBits.write(2, pin.volume);
						}
						
						var shapeString: String = shapeBits.encodeBase64(base64IntToChar);
						var shapeIndex: int = recentShapes.indexOf(shapeString);
						if (shapeIndex == -1) {
							bits.write(2, 1); // new shape
							bits.concat(shapeBits);
						} else {
							bits.write(1, 1); // old shape
							bits.writeLongTail(0, 0, shapeIndex);
							recentShapes.splice(shapeIndex, 1);
						}
						recentShapes.unshift(shapeString);
						if (recentShapes.length > 10) recentShapes.pop();
						
						var allPitches: Array = t.pitches.concat(pitchBends);
						for (i = 0; i < allPitches.length; i++) {
							var pitch: int = allPitches[i];
							var pitchIndex: int = recentPitches.indexOf(pitch);
							if (pitchIndex == -1) {
								var interval: int = 0;
								var pitchIter: int = lastPitch;
								if (pitchIter < pitch) {
									while (pitchIter != pitch) {
										pitchIter++;
										if (recentPitches.indexOf(pitchIter) == -1) interval++;
									}
								} else {
									while (pitchIter != pitch) {
										pitchIter--;
										if (recentPitches.indexOf(pitchIter) == -1) interval--;
									}
								}
								bits.write(1, 0);
								bits.writePitchInterval(interval);
							} else {
								bits.write(1, 1);
								bits.write(3, pitchIndex);
								recentPitches.splice(pitchIndex, 1);
							}
							recentPitches.unshift(pitch);
							if (recentPitches.length > 8) recentPitches.pop();
							
							if (i == t.pitches.length - 1) {
								lastPitch = t.pitches[0];
							} else {
								lastPitch = pitch;
							}
						}
						curPart = t.end;
					}
					
					if (curPart < beats * parts) {
						bits.write(2, 0); // rest
						bits.writePartDuration(beats * parts - curPart);
					}
				} else {
					bits.write(1, 0);
				}
			}
		}
		var bitString: String = bits.encodeBase64(base64IntToChar);
		var stringLength: int = bitString.length;
		var digits: String = "";
		while (stringLength > 0) {
			digits = base64IntToChar[stringLength & 0x3f] + digits;
			stringLength = stringLength >> 6;
		}
		result += base64IntToChar[digits.length];
		result += digits;
		result += bitString;
		
		return result;
	}
	*/

	// } endregion

	// { region TO JSON
	
	/* TODO:
	public function toJsonObject(enableIntro: Boolean = true, loopCount: int = 1, enableOutro: Boolean = true): Object {
		const channelArray: Array = [];
		var i: int;
		for (var channel: int = 0; channel < Music.numChannels; channel++) {
			const instrumentArray: Array = [];
			for (i = 0; i < this.instruments; i++) {
				if (channel == 3) {
					instrumentArray.push({
						volume: (5 - this.instrumentVolumes[channel][i]) * 20,
						wave: Music.drumNames[this.instrumentWaves[channel][i]],
						envelope: Music.attackNames[this.instrumentAttacks[channel][i]]
					});
				} else {
					instrumentArray.push({
						volume: (5 - this.instrumentVolumes[channel][i]) * 20,
						wave: Music.waveNames[this.instrumentWaves[channel][i]],
						envelope: Music.attackNames[this.instrumentAttacks[channel][i]],
						filter: Music.filterNames[this.instrumentFilters[channel][i]],
						chorus: Music.chorusNames[this.instrumentChorus[channel][i]],
						effect: Music.effectNames[this.instrumentEffects[channel][i]]
					});
				}
			}
			
			const patternArray: Array = [];
			for each (var pattern: BarPattern in this.channelPatterns[channel]) {
				const pitchArray: Array = [];
				for each (var note: Note in pattern.notes) {
					const pointArray: Array = [];
					for each (var pin: NotePin in note.pins) {
						pointArray.push({
							tick: pin.time + note.start,
							pitchBend: pin.interval,
							volume: Math.round(pin.volume * 100.0 / 3.0)
						});
					}
					
					pitchArray.push({
						pitches: note.pitches,
						points: pointArray
					});
				}
				
				patternArray.push({
					instrument: pattern.instrument + 1,
					pitches: pitchArray
				});
			}
			
			const sequenceArray: Array = [];
			if (enableIntro) for (i = 0; i < this.loopStart; i++) {
				sequenceArray.push(this.channelBars[channel][i]);
			}
			for (var l: int = 0; l < loopCount; l++) for (i = this.loopStart; i < this.loopStart + this.loopLength; i++) {
				sequenceArray.push(this.channelBars[channel][i]);
			}
			if (enableOutro) for (i = this.loopStart + this.loopLength; i < this.bars; i++) {
				sequenceArray.push(this.channelBars[channel][i]);
			}
			
			channelArray.push({
				octaveScrollBar: this.channelOctaves[channel],
				instruments: instrumentArray,
				patterns: patternArray,
				sequence: sequenceArray
			});
		}
		
		return {
			version: latestVersion,
			scale: Music.scaleNames[this.scale],
			key: Music.keyNames[this.key],
			introBars: this.loopStart,
			loopBars: this.loopLength,
			beatsPerBar: this.beats,
			ticksPerBeat: this.parts,
			beatsPerMinute: this.getBeatsPerMinute(), // represents tempo
			reverb: this.reverb,
			//outroBars: this.bars - this.loopStart - this.loopLength; // derive this from bar arrays?
			//patternCount: this.patterns, // derive this from pattern arrays?
			//instrumentsPerChannel: this.instruments, //derive this from instrument arrays?
			channels: channelArray
		};
	}
	*/

	// } endregion

	// } endregion

}

class BitFieldReader
{

	var bits:Array<Bool> = [];
	var readIndex:Int = 0;
	
	public function new(base64CharToInt:Map<String, Int>, source: String)
	{
		for (char in source.split(''))
		{
			var value:Int = base64CharToInt[char];
			bits.push((value & 0x20) != 0);
			bits.push((value & 0x10) != 0);
			bits.push((value & 0x08) != 0);
			bits.push((value & 0x04) != 0);
			bits.push((value & 0x02) != 0);
			bits.push((value & 0x01) != 0);
		}
	}

	public function read(bitCount:Int):Int
	{
		var result:Int = 0;
		while (bitCount > 0) {
			result = result << 1;
			result += bits[readIndex++] ? 1 : 0;
			bitCount--;
		}
		return result;
	}

	public function readLongTail(minValue:Int, minBits:Int):Int
	{
		var result:Int = minValue;
		var numBits:Int = minBits;
		while (bits[readIndex++]) {
			result += 1 << numBits;
			numBits++;
		}
		while (numBits > 0) {
			numBits--;
			if (bits[readIndex++]) {
				result += 1 << numBits;
			}
		}
		return result;
	}

	public function readPartDuration():Int return readLongTail(1, 2);
	public function readPinCount():Int return readLongTail(1, 0);

	public function readPitchInterval():Int
	{
		return readLongTail(1, 3) * (read(1) > 0 ? -1 : 1);
	}

}

typedef Shape = {
	pitchCount:Int,
	pinCount:Int,
	initialVolume:Int,
	pins:Array<PinObj>,
	length:Int,
	bendCount:Int
}

typedef PinObj = {
	pitchBend:Bool,
	time:Int,
	volume:Int,
}

// { region **NOT NEEDED FOR PLAYBACK**

class BitFieldWriter
{

	var bits:Array<Bool> = [];

	/* TODO:
	public function write(bitCount: int, value: int): void {
		bitCount--;
		while (bitCount >= 0) {
			bits.push(((value >> bitCount) & 1) == 1);
			bitCount--;
		}
	}
	
	public function writeLongTail(minValue: int, minBits: int, value: int): void {
		if (value < minValue) throw new Error();
		value -= minValue;
		var numBits: int = minBits;
		while (value >= (1 << numBits)) {
			bits.push(true);
			value -= 1 << numBits;
			numBits++;
		}
		bits.push(false);
		while (numBits > 0) {
			numBits--;
			bits.push((value & (1 << numBits)) != 0);
		}
	}
	
	public function writePartDuration(value: int): void {
		writeLongTail(1, 2, value);
	}
	
	public function writePinCount(value: int): void {
		writeLongTail(1, 0, value);
	}
	
	public function writePitchInterval(value: int): void {
		if (value < 0) {
			write(1, 1); // sign
			writeLongTail(1, 3, -value);
		} else {
			write(1, 0); // sign
			writeLongTail(1, 3, value);
		}
	}
	
	public function concat(other: BitFieldWriter): void {
		bits = bits.concat(other.bits);
	}
	
	public function encodeBase64(base64: Array): String {
		var result: String = "";
		for (var i: int = 0; i < bits.length; i += 6) {
			var value: int = 0;
			if (bits[i+0]) value += 0x20;
			if (bits[i+1]) value += 0x10;
			if (bits[i+2]) value += 0x08;
			if (bits[i+3]) value += 0x04;
			if (bits[i+4]) value += 0x02;
			if (bits[i+5]) value += 0x01;
			result += base64[value];
			
		}
		return result;
	}
	*/

}

// } endregion