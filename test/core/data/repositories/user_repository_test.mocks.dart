import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {
  @override
  Reference ref([String? path]) =>
      super.noSuchMethod(
            Invocation.method(#ref, [path]),
            returnValue: MockReference(),
            returnValueForMissingStub: MockReference(),
          )
          as Reference;
}

class MockReference extends Mock implements Reference {
  @override
  Reference child(String? path) =>
      super.noSuchMethod(
            Invocation.method(#child, [path]),
            returnValue: this,
            returnValueForMissingStub: this,
          )
          as Reference;

  @override
  Future<void> delete() =>
      super.noSuchMethod(
            Invocation.method(#delete, []),
            returnValue: Future<void>.value(),
            returnValueForMissingStub: Future<void>.value(),
          )
          as Future<void>;
}
