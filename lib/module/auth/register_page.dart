import 'package:faisal_pedia/module/auth/register_notifier.dart';
import 'package:faisal_pedia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterNotifier(context: context),
      child: Consumer<RegisterNotifier>(
        builder: (context, value, child) => Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: Center(
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width > 600
                    ? 400
                    : MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: value.keyForm,
                          child: ListView(
                            children: [
                              const Text(
                                "Nama Lengkap",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: value.namaLengkap,
                                textInputAction: TextInputAction.next,
                                validator: (e) {
                                  if (e == null || e.isEmpty) {
                                    return "Nama lengkap tidak boleh kosong";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Faisal Arrahman",
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: value.email,
                                textInputAction: TextInputAction.next,
                                validator: (e) {
                                  if (e == null || e.isEmpty) {
                                    return "Email tidak boleh kosong";
                                  }
                                  if (!e.contains("@")) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "faisal@example.com",
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: value.password,
                                obscureText: value.obscure,
                                textInputAction: TextInputAction.done,
                                validator: (e) {
                                  if (e == null || e.isEmpty) {
                                    return "Password tidak boleh kosong";
                                  }
                                  if (e.length < 6) {
                                    return "Minimal 6 karakter";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: IconButton(
                                      onPressed: value.gantiobscure,
                                      icon: Icon(
                                        value.obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                  hintText: "Masukkan password anda",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Konfirmasi Password",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: value.confirmPassword,
                                obscureText: value.obscureConfirm,
                                textInputAction: TextInputAction.done,
                                validator: (e) {
                                  if (e == null || e.isEmpty) {
                                    return "Konfirmasi password tidak boleh kosong";
                                  }
                                  if (e.length < 6) {
                                    return "Minimal 6 karakter";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: IconButton(
                                      onPressed: value.confimGantiObscure,
                                      icon: Icon(
                                        value.obscureConfirm
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                  hintText: "Masukkan konfirmasi password anda",
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: value.cek,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: colorPrimary,
                                ),
                                child: const Text(
                                  "Daftar",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
