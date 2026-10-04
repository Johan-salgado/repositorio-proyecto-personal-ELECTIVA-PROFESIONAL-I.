"""Genera el PDF de evidencias del Taller 3 a partir de capturas/taller3/.

Uso:  pip install reportlab pillow
      python generar_pdf_evidencias.py
"""
import os
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.units import cm
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas

REPO = "https://github.com/Johan-salgado/repositorio-proyecto-personal-ELECTIVA-PROFESIONAL-I..git"
CARPETA = "capturas/taller3"
SALIDA = "Evidencias_Taller3_Johan_Salgado.pdf"

# (sección, título, archivo, descripción)
EVIDENCIAS = [
    ("Aplicación", "Menú principal", "menu_principal.png",
     "Pantalla de inicio de la aplicación (emulador Pixel 9 Pro). Desde aquí se accede a las tres pantallas del "
     "Taller 3: Future/async/await, Cronómetro (Timer) y Tarea pesada (Isolate), además del Taller 1."),

    ("1. Cronómetro (Timer)", "Estado inicial", "cronometro_inicial.png",
     "El cronómetro antes de empezar: marcador en 00:00.0 y «Estado: detenido». Solo el botón «Iniciar» está "
     "habilitado; Pausar, Reanudar y Reiniciar permanecen deshabilitados."),
    ("1. Cronómetro (Timer)", "Iniciar", "cronometro_iniciar.png",
     "Tras presionar «Iniciar», el marcador avanza (00:01.9) y el estado es «corriendo». Un Timer.periodic de 100 ms "
     "refresca la pantalla. Quedan habilitados «Pausar» y «Reiniciar»."),
    ("1. Cronómetro (Timer)", "Pausar", "cronometro_pausar.png",
     "Al presionar «Pausar» el Timer se cancela y el tiempo queda detenido en 00:08.0 con estado «pausado». "
     "Se habilitan «Reanudar» y «Reiniciar»."),
    ("1. Cronómetro (Timer)", "Reanudar", "cronometro_reanudar.png",
     "Al presionar «Reanudar» se crea un nuevo Timer y el conteo continúa desde el tiempo acumulado (00:08.0 → "
     "00:09.1), no desde cero. El estado vuelve a «corriendo»."),
    ("1. Cronómetro (Timer)", "Reiniciar", "cronometro_reiniciar.png",
     "Al presionar «Reiniciar» se cancela el Timer, el marcador vuelve a 00:00.0 y el estado a «detenido». "
     "(El Timer también se cancela en dispose() al salir de la vista)."),

    ("2. Future / async / await", "Estado en espera", "future_espera.png",
     "Pantalla antes de consultar: estado «En espera» y lista de orden de ejecución vacía. Los dos botones "
     "(«Consultar datos» y «Consultar con error») están habilitados."),
    ("2. Future / async / await", "Cargando…", "future_cargando.png",
     "Durante los 3 s de Future.delayed el estado es «Cargando…», el indicador gira (la UI no está bloqueada) y los "
     "botones se deshabilitan. En la consola se ve el orden: A (antes de llamar), 1. ANTES, [Servicio] consulta "
     "iniciada, 2. DURANTE y B (se imprime sin esperar el resultado, porque la función no fue esperada con await)."),
    ("2. Future / async / await", "Éxito", "future_exito.png",
     "El Future se completó y await entregó el resultado: estado «Éxito» con los 3 registros recibidos. La lista y la "
     "consola muestran el orden 1. ANTES → 2. DURANTE → 3. DESPUÉS (la consulta terminó con éxito)."),
    ("2. Future / async / await", "Error", "future_error.png",
     "Con «Consultar con error» el Future lanza una excepción que se captura con try/catch: estado «Error» y el "
     "mensaje «No se pudo conectar con el servidor (error simulado)». El paso 3 indica que terminó con error."),
    ("2. Future / async / await", "Consola – orden de ejecución", "consola_future.png",
     "Recorte de la consola de depuración con el orden de ejecución: 1. ANTES, [Servicio] Consulta iniciada, "
     "2. DURANTE, B. Después de llamar (sin esperar), [Servicio] Datos listos y 3. DESPUÉS (éxito). "
     "Las líneas D/EGL_emulation son métricas del emulador."),

    ("3. Isolate (tarea pesada)", "Ejecutando en el Isolate", "isolate_ejecutando.png",
     "Se lanzó la suma grande (n = 500 000 000) con Isolate.spawn. La barra de progreso se anima y el resto de la "
     "interfaz responde, es decir, la UI no está bloqueada. Consola: «[Main] Lanzando Isolate» e "
     "«[Isolate] Iniciado. Calculando suma…»."),
    ("3. Isolate (tarea pesada)", "Resultado y tiempos", "isolate_pantalla.png",
     "El Isolate terminó y envió el resultado por mensaje (SendPort): «Resultado recibido: 1000000001» y "
     "«Tiempo con Isolate: 38893 ms» (modo debug en emulador, por eso tarda; en release es mucho menor). "
     "La consola muestra los mismos mensajes."),
    ("3. Isolate (tarea pesada)", "Consola – mensajes del Isolate", "consola_isolate.png",
     "Recorte de la consola de la misma ejecución: [Main] lanza el Isolate, [Isolate] inicia el cálculo, "
     "[Isolate] termina y envía el resultado, y [Main] recibe el resultado y el tiempo (38893 ms)."),
    ("3. Isolate (tarea pesada)", "Comparación: sin Isolate", "isolate_sin_isolate.png",
     "Prueba de contraste: el mismo cálculo ejecutado en el hilo principal («Calculando en el hilo principal»). "
     "La interfaz queda congelada mientras dura la tarea."),
    ("3. Isolate (tarea pesada)", "Sin Isolate: la app no responde", "isolate_anr.png",
     "Resultado de la prueba anterior: Android muestra «flutter_application_1 isn't responding». Esto demuestra "
     "por qué las tareas CPU-bound deben ir en un Isolate y no en el hilo de la UI."),
]

W, H = landscape(A4)
M = 1.5 * cm


def envolver(c, texto, fuente, tam, ancho):
    lineas, actual = [], ""
    for palabra in texto.split():
        prueba = (actual + " " + palabra).strip()
        if c.stringWidth(prueba, fuente, tam) <= ancho:
            actual = prueba
        else:
            lineas.append(actual)
            actual = palabra
    lineas.append(actual)
    return lineas


def portada(c):
    y = H - 3 * cm
    c.setFont("Helvetica-Bold", 22)
    c.drawString(M, y, "Taller 3 – Segundo plano, asincronía y servicios en Flutter")
    y -= 1.3 * cm
    c.setFont("Helvetica", 13)
    for t in ["Estudiante: Johan Eliu Salgado Castro        Código: 230232033",
              "Asignatura: Electiva Profesional I – UCEVA"]:
        c.drawString(M, y, t)
        y -= 0.8 * cm
    y -= 0.6 * cm
    c.setFont("Helvetica-Bold", 14)
    c.drawString(M, y, "URL del repositorio:")
    y -= 0.8 * cm
    c.setFillColorRGB(0, 0.2, 0.8)
    c.setFont("Helvetica", 11)
    c.drawString(M, y, REPO)
    c.linkURL(REPO, (M, y - 3, M + c.stringWidth(REPO, "Helvetica", 11), y + 12))
    c.setFillColorRGB(0, 0, 0)
    y -= 1.2 * cm
    c.setFont("Helvetica", 12)
    for t in ["Rama de trabajo: feature/taller_segundo_plano  →  Pull Request a dev  →  integración a main.",
              "",
              "Contenido de las evidencias:",
              "   1. Cronómetro con Timer: iniciar, pausar, reanudar y reiniciar.",
              "   2. Future con async/await: pantalla de carga, éxito, error y orden de ejecución en consola.",
              "   3. Isolate para tarea pesada: pantalla con tiempos, consola con mensajes y comparación sin Isolate.",
              "",
              "Entorno: emulador Pixel 9 Pro (Android), Flutter ejecutado en modo debug desde VS Code."]:
        c.drawString(M, y, t)
        y -= 0.7 * cm
    c.showPage()


def main():
    c = canvas.Canvas(SALIDA, pagesize=(W, H))
    c.setTitle("Evidencias Taller 3 – Johan Salgado")
    portada(c)

    for i, (seccion, titulo, archivo, desc) in enumerate(EVIDENCIAS, 1):
        y = H - 1.6 * cm
        c.setFont("Helvetica", 10)
        c.setFillColorRGB(0.4, 0.4, 0.4)
        c.drawString(M, y, seccion)
        c.setFillColorRGB(0, 0, 0)
        y -= 0.75 * cm
        c.setFont("Helvetica-Bold", 16)
        c.drawString(M, y, f"Evidencia {i}: {titulo}")
        y -= 0.7 * cm
        c.setFont("Helvetica", 10.5)
        for linea in envolver(c, desc, "Helvetica", 10.5, W - 2 * M):
            c.drawString(M, y, linea)
            y -= 0.45 * cm
        y -= 0.2 * cm

        ruta = os.path.join(CARPETA, archivo)
        alto = y - 1.0 * cm
        if os.path.exists(ruta):
            img = ImageReader(ruta)
            iw, ih = img.getSize()
            esc = min((W - 2 * M) / iw, alto / ih)
            dw, dh = iw * esc, ih * esc
            x = (W - dw) / 2
            c.drawImage(img, x, y - dh, dw, dh)
            c.setStrokeColorRGB(0.7, 0.7, 0.7)
            c.rect(x, y - dh, dw, dh)
        else:
            c.setDash(4, 3)
            c.rect(M, y - alto, W - 2 * M, alto)
            c.setDash()
            c.drawCentredString(W / 2, y - alto / 2, f"[Falta captura: {ruta}]")
        c.setFont("Helvetica", 8)
        c.setFillColorRGB(0.5, 0.5, 0.5)
        c.drawRightString(W - M, 0.8 * cm, f"Taller 3 – Johan Salgado · página {i + 1}")
        c.setFillColorRGB(0, 0, 0)
        c.showPage()

    c.save()
    print("PDF generado:", SALIDA)


if __name__ == "__main__":
    main()
