module MorseCode

using PortAudio

codemap = Dict(
               'A' =>  ".-",
               'B' =>  "-...",
               'C' =>  "-.-.",
               'D' =>  "-..",
               'E' =>  ".",
               'F' =>  "..-.",
               'G' =>  "--.",
               'H' =>  "....",
               'I' =>  "..",
               'J' =>  ".---",
               'K' =>  "-.-",
               'L' =>  ".-..",
               'M' =>  "--",
               'N' =>  "-.",
               'O' =>  "---",
               'P' =>  ".--.",
               'Q' =>  "--.-",
               'R' =>  ".-.",
               'S' =>  "...",
               'T' =>  "-",
               'U' =>  "..-",
               'V' =>  "...-",
               'W' =>  ".--",
               'X' =>  "-..-",
               'Y' =>  "-.--",
               'Z' =>  "--..",
               '1' =>  ".----",
               '2' =>  "..---",
               '3' =>  "...--",
               '4' =>  "....-",
               '5' =>  ".....",
               '6' =>  "-....",
               '7' =>  "--...",
               '8' =>  "---..",
               '9' =>  "----.",
               '0' =>  "-----",
               '.' => ".-.-.-",
               ',' => "--..--",
               ':' => "---...",
               '?' => "..--..",
               '_' => "..--.-",
              )

"""
    play(text::String)

Convert text to morse code and play it with 440Hz sine wave.
"""
function play(text::String)
    S = 44100
    PortAudioStream(0, 1) do stream
        for ch in text
            if ch == ' '
                write(stream, zeros(Float64, trunc(Int, S*0.7)))
                continue
            end
            encoded = encode(ch)
            for code in encoded
                duration = code == '-' ? 0.3 : 0.1
                x = sin.(2pi*(1:S*duration)*440/S)
                write(stream, x)
                write(stream, zeros(Float64, trunc(Int, S*0.05)))
            end
            write(stream, zeros(Float64, trunc(Int, S*0.2)))
        end
    end
end

"""
    from_mic(cb = (Char) -> ())

Decode morse code from default audio input.
"""
function from_mic(cb = (Char) -> ())
    PortAudioStream(1, 0) do stream
        input(stream, cb)
    end
end


"""
    input(stream, cb = (Char) -> ())

Decode morse code from PortAudioStream.
"""
function input(stream, cb = (Char) -> ())
    counts = [0, 0]
    code = ""
    while true
        block = read(stream, 512)
        blockmax = maximum(abs.(block))
        if blockmax > 0.008
            counts[1] += 1
            counts[2] = 0
        else
            if counts[1] > 15
                code *= "-"
            elseif counts[1] > 0
                code *= "."
            end
            counts[1] = 0
            counts[2] += 1

            if counts[2] > 10
                decoded = decode(code)
                if decoded != nothing
                    cb(decoded)
                end
                code = ""
            end
        end
    end
end

"""
    encode(char::Char)

Encode a character into a morse code string e.g. 'A' -> "-.". 
"""
function encode(char::Char)
    Base.get(codemap, char, nothing)
end

"""
    decode(char::Char)

Decode a morse code string into a character e.g. "-." -> 'A'. 
"""
function decode(code::String)
    result = [k for (k, v) in codemap if v == code]
    if isempty(result)
        nothing
    else
        first(result)
    end
end

end
