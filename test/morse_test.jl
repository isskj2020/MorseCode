
@testset "Encoder/Decoder" begin
    @test MorseCode.encode('A') == ".-"
    @test MorseCode.decode(".-") == 'A'
end
