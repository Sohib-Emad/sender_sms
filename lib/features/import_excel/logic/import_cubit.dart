import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/core/services/excel/excel_reader.dart';

abstract class ImportState extends Equatable {
  const ImportState();
  @override
  List<Object?> get props => [];
}

class ImportInitial extends ImportState {}

class ImportLoading extends ImportState {}

class ImportSuccess extends ImportState {
  final List<Student> students;
  final String filePath;
  final String fileName;

  const ImportSuccess({
    required this.students,
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [students, filePath, fileName];
}

class ImportError extends ImportState {
  final String message;
  const ImportError(this.message);
  @override
  List<Object?> get props => [message];
}

class ImportCubit extends Cubit<ImportState> {
  ImportCubit() : super(ImportInitial());

  Future<void> pickFile() async {
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

      final students = await ExcelReader.importFromFile(file.path!);
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
      final msg = e.toString();
      if (msg.contains('Null check') || msg.contains('null value')) {
        emit(const ImportError('تعذر قراءة الملف. تأكد من أن الملف بصيغة Excel صحيحة'));
      } else {
        emit(ImportError(msg));
      }
    }
  }

  void reset() => emit(ImportInitial());
}
