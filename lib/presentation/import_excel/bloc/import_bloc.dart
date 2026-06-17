import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'import_event.dart';
import 'import_state.dart';
import '../../../domain/usecases/import_excel_usecase.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportExcelUseCase _importExcelUseCase;

  ImportBloc(this._importExcelUseCase) : super(ImportInitial()) {
    on<ImportPickFile>(_onPickFile);
    on<ImportReset>(_onReset);
  }

  Future<void> _onPickFile(
      ImportPickFile event, Emitter<ImportState> emit) async {
    emit(ImportLoading());
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        emit(ImportInitial());
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        emit(const ImportError('تعذر الوصول للملف'));
        return;
      }

      final students = await _importExcelUseCase(file.path!);

      if (students.isEmpty) {
        emit(const ImportError('لم يتم العثور على بيانات في الملف'));
        return;
      }

      emit(ImportSuccess(
        students: students,
        filePath: file.path!,
        fileName: file.name,
      ));
    } catch (e) {
      final message = e.toString();
      // Replace cryptic null errors with user-friendly message
      if (message.contains('Null check') || message.contains('null value')) {
        emit(const ImportError('تعذر قراءة الملف. تأكد من أن الملف بصيغة Excel صحيحة'));
      } else {
        emit(ImportError(message));
      }
    }
  }

  void _onReset(ImportReset event, Emitter<ImportState> emit) {
    emit(ImportInitial());
  }
}
