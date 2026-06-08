import 'package:flutter/material.dart';

// Mô hình Sinh viên
class Student {
  final String ma;
  final String hoVaTen;
  final double diemTotNghiep;

  Student({
    required this.ma,
    required this.hoVaTen,
    required this.diemTotNghiep,
  });
}

class StudentLabScreen extends StatefulWidget {
  const StudentLabScreen({super.key});

  @override
  State<StudentLabScreen> createState() => _StudentLabScreenState();
}

class _StudentLabScreenState extends State<StudentLabScreen> {
  // Biến dữ liệu chứa danh sách sinh viên
  final List<Student> _students = [
    Student(ma: 'SV01', hoVaTen: 'Nguyễn Văn A', diemTotNghiep: 8.5),
    Student(ma: 'SV02', hoVaTen: 'Trần Thị B', diemTotNghiep: 7.0),
  ];

  void _addNewSinhVien(String ma, String hoVaTen, double diem) {
    setState(() {
      _students.add(Student(
        ma: ma,
        hoVaTen: hoVaTen,
        diemTotNghiep: diem,
      ));
    });
  }

  // Hàm hiển thị Modal Bottom Sheet thêm sinh viên (Giống Slide)
  void _showAddStudentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewSinhVien(addSinhVien: _addNewSinhVien),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng Sinh Viên (Modal)'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.school)),
              title: Text(student.hoVaTen, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mã SV: ${student.ma} - Điểm: ${student.diemTotNghiep}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _students.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentBottomSheet(context),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget Tách phần kiểm tra dữ liệu ra thành phương thức riêng (Giống Slide 7)
class NewSinhVien extends StatefulWidget {
  final Function(String, String, double) addSinhVien;

  const NewSinhVien({super.key, required this.addSinhVien});

  @override
  State<NewSinhVien> createState() => _NewSinhVienState();
}

class _NewSinhVienState extends State<NewSinhVien> {
  final maController = TextEditingController();
  final hoVaTenController = TextEditingController();
  final diemTotNghiepController = TextEditingController();

  void submitData() {
    final enteredMa = maController.text;
    final enteredHoVaTen = hoVaTenController.text;
    
    if (diemTotNghiepController.text.isEmpty) return;
    final enteredDiemTotNghiep = double.parse(diemTotNghiepController.text);

    if (enteredMa.isEmpty || enteredHoVaTen.isEmpty || enteredDiemTotNghiep <= 0) {
      return;
    }

    widget.addSinhVien(
      maController.text,
      hoVaTenController.text,
      double.parse(diemTotNghiepController.text),
    );

    Navigator.of(context).pop(); // Đóng Modal Bottom Sheet sau khi add xong
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding để không bị bàn phím che khuất
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: maController,
              decoration: const InputDecoration(labelText: 'Mã SV'),
            ),
            TextField(
              controller: hoVaTenController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: diemTotNghiepController,
              decoration: const InputDecoration(labelText: 'Điểm tốt nghiệp'),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => submitData(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitData,
              child: const Text('Thêm sinh viên'),
            ),
          ],
        ),
      ),
    );
  }
}
