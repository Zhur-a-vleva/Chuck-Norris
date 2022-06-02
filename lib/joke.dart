import 'package:json_annotation/json_annotation.dart';

part 'joke.g.dart';

@JsonSerializable()
class Joke {
  // POJO class Joke for json serialization
  Joke(this.iconUrl, this.id, this.url, this.value);

  String iconUrl;
  String id;
  String url;
  String value;

  factory Joke.fromJson(Map<String, dynamic> json) => _$JokeFromJson(json);
}
