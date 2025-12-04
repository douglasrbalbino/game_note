import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart'; // Importante para navegar para a Home

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Controle de Loading
  bool _isLoading = false;
  
  final Color _headerPurple = const Color(0xFFD1C4E9);
  final Color _accentPurple = const Color(0xFF7C4DFF);

  void _doSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos obrigatórios.")),
      );
      return;
    }

    // Ativa loading e esconde teclado
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // 1. Cria a conta no Firebase (isso já faz o login automático)
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // 2. Navega DIRETO para a Home e remove todas as telas anteriores (Login/Cadastro)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false, // Remove tudo da pilha
        );
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        String message = "Erro ao cadastrar.";
        if (e.code == 'weak-password') {
          message = "A senha é muito fraca.";
        } else if (e.code == 'email-already-in-use') {
          message = "Este e-mail já está em uso.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Criar Conta",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _accentPurple),
            ),
            const SizedBox(height: 10),
            Text("Preencha os dados abaixo para começar.", style: TextStyle(color: Colors.grey[600])),
            
            const SizedBox(height: 40),

            // Nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome Completo",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // E-mail
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-mail",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Celular (Opcional)
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Celular (Opcional)",
                prefixIcon: const Icon(Icons.phone_android_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
                helperText: "Usado para verificação em duas etapas."
              ),
            ),
            const SizedBox(height: 15),

            // Senha
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doSignUp, // Bloqueia clique duplo
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text("CADASTRAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}