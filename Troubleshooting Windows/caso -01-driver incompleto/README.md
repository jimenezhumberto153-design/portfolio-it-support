# Caso 01: Dispositivo deshabilitado — Simulación de conflicto de hardware

## 🎫 Síntoma reportado
Se simula un escenario de conflicto de hardware deshabilitando manualmente un dispositivo desde el Administrador de dispositivos, con el fin de practicar el proceso de diagnóstico ante un dispositivo con error (Código 22).

## 🔍 Diagnóstico

**1. Verificación en Administrador de dispositivos**

Se identificó el dispositivo deshabilitado, mostrado con el ícono de advertencia correspondiente.

![Dispositivo deshabilitado](./capturas/01-error-visible.png)

**2. Revisión del código de error**

Se abrieron las propiedades del dispositivo, confirmando el código de error asociado al estado deshabilitado.

![Código de error en propiedades](./capturas/02-codigo-error.png)

## 🎯 Causa raíz
Dispositivo deshabilitado intencionalmente para simular un escenario de conflicto de hardware con fines de práctica, replicando el proceso de diagnóstico que se aplicaría ante un Código 22 real.

## ✅ Solución aplicada
1. Se accedió a Administrador de dispositivos
2. Se identificó el dispositivo con el ícono de advertencia
3. Click derecho sobre el dispositivo → **Habilitar dispositivo**
4. Se verificó que el ícono de advertencia desapareciera

![Dispositivo habilitado correctamente](./capturas/03-solucion-aplicada.png)

## 📌 Prevención / Notas
- Ante un Código 22 real (no simulado), el mismo proceso de habilitar el dispositivo suele resolver el problema; si persiste, se recomienda revisar o reinstalar el driver