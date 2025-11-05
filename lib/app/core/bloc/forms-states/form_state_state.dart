abstract class FormSubmitStatus {
  const FormSubmitStatus();
}

class InitialFormSubmitStatus extends FormSubmitStatus {
  const InitialFormSubmitStatus();
}

class FormSubmitProgress extends FormSubmitStatus {}

class FormSubmitSuccesfull extends FormSubmitStatus {
  final String? message;
  const FormSubmitSuccesfull({this.message});
}

class FormSubmitFailed extends FormSubmitStatus {
  final String exception;
  FormSubmitFailed(this.exception);
}
