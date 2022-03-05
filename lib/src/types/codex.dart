typedef CodexFunction = dynamic Function(dynamic value);

class Codex {
  const Codex({
    required this.decoder,
    required this.encoder,
  });

  final CodexFunction decoder;
  final CodexFunction encoder;

  dynamic decode(dynamic value) => decoder(value);
  dynamic encode(dynamic value) => encoder(value);
}
