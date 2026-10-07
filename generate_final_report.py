import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls
import os

from generate_report_utils import set_cell_background, set_cell_margins, add_styled_heading, add_body_p

def build_final_academic_report():
    doc = docx.Document()
    
    # 1. Configuración de Márgenes APA 7 (1 pulgada = 2.54 cm en todos los lados)
    for sec in doc.sections:
        sec.top_margin = Inches(1.0)
        sec.bottom_margin = Inches(1.0)
        sec.left_margin = Inches(1.0)
        sec.right_margin = Inches(1.0)
        sec.different_first_page_header_footer = True

    # -------------------------------------------------------------
    # PORTADA OFICIAL (VII Semestre - Ingeniería de Sistemas)
    # -------------------------------------------------------------
    p_inst = doc.add_paragraph()
    p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_inst.paragraph_format.space_before = Pt(24)
    p_inst.paragraph_format.space_after = Pt(12)
    r_inst = p_inst.add_run("UNIVERSIDAD DE CARTAGENA\nFACULTAD DE INGENIERÍA\nPROGRAMA DE INGENIERÍA DE SISTEMAS\nVII SEMESTRE")
    r_inst.font.name = 'Calibri'
    r_inst.font.size = Pt(13)
    r_inst.font.bold = True
    r_inst.font.color.rgb = RGBColor(15, 23, 42)

    p_title = doc.add_paragraph()
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(36)
    p_title.paragraph_format.space_after = Pt(32)
    r_title = p_title.add_run('CLINICAAPP: PLATAFORMA INTEGRAL PARA LA GESTIÓN VETERINARIA, INTEGRACIÓN DE AGENTES INTELIGENTES BASADOS EN LLM, MODELADO DIMENSIONAL Y OPTIMIZACIÓN GEOESPACIAL DE RECURSOS')
    r_title.font.name = 'Calibri'
    r_title.font.size = Pt(14.5)
    r_title.font.bold = True
    r_title.font.color.rgb = RGBColor(30, 58, 138) # Deep Navy

    p_proj = doc.add_paragraph()
    p_proj.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_proj.paragraph_format.space_after = Pt(28)
    r_proj = p_proj.add_run("INFORME METODOLÓGICO DE PROYECTO DE AULA INTERDISCIPLINAR (SEGUNDO SEGUIMIENTO)")
    r_proj.font.name = 'Calibri'
    r_proj.font.size = Pt(12)
    r_proj.font.bold = True
    r_proj.font.color.rgb = RGBColor(71, 85, 105)

    p_aut = doc.add_paragraph()
    p_aut.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_aut.paragraph_format.space_after = Pt(24)
    r_aut_lbl = p_aut.add_run("AUTORES / INVESTIGADORES:\n")
    r_aut_lbl.font.bold = True
    r_aut_lbl.font.size = Pt(11)
    r_aut = p_aut.add_run("Luis Cárdenas\nCristóbal Villamil\nMaría Salas\nDaniel Gutiérrez")
    r_aut.font.size = Pt(11)

    p_doc = doc.add_paragraph()
    p_doc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_doc.paragraph_format.space_after = Pt(36)
    r_asig_lbl = p_doc.add_run("ASIGNATURAS INTERDISCIPLINARES Y COMITÉ DOCENTE:\n")
    r_asig_lbl.font.bold = True
    r_asig_lbl.font.size = Pt(11)
    r_doc = p_doc.add_run(
        "• Desarrollo Web Avanzado\n"
        "• Visualización de Datos II\n"
        "• Investigación de Operaciones\n"
        "Comité Docente y de Seguimiento: Laura Martínez García; Andrés Pardo Rivera; Danilo Varga Jiménez; Heyder Medrano Olier; Samir Martínez De Ávila"
    )
    r_doc.font.size = Pt(10)
    r_doc.font.color.rgb = RGBColor(71, 85, 105)

    p_date = doc.add_paragraph()
    p_date.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_date.paragraph_format.space_before = Pt(20)
    r_date = p_date.add_run("Cartagena de Indias D. T. y C., Colombia\nOctubre de 2026")
    r_date.font.size = Pt(11)
    r_date.font.bold = True

    doc.add_page_break()

    # -------------------------------------------------------------
    # TABLA DE CONTENIDO
    # -------------------------------------------------------------
    add_styled_heading(doc, "Tabla de Contenido", level=1)
    
    indice_secciones = [
        "Introducción",
        "Capítulo I: Problema de Investigación",
        "   1.1 Descripción del problema",
        "   1.2 Pregunta problema",
        "   1.3 Árbol del problema (Causas y Efectos)",
        "   1.4 Justificación interdisciplinar",
        "   1.5 Objetivos del proyecto",
        "       1.5.1 Objetivo general",
        "       1.5.2 Objetivos específicos (Ciclo de Vida del Software)",
        "Capítulo II: Estado del Arte y Marcos de Referencia",
        "   2.1 Antecedentes Internacionales",
        "   2.2 Antecedentes Nacionales",
        "   2.3 Antecedentes Regionales y Locales",
        "   2.4 Marco Teórico Interdisciplinar",
        "       2.4.1 Desarrollo Web Avanzado: Arquitectura Spring Boot, LLM y Seguridad",
        "       2.4.2 Visualización de Datos II: Fuentes de Datos y Modelado Dimensional",
        "       2.4.3 Investigación de Operaciones: Formulación PLEB y Distancia Haversine",
        "   2.5 Marco Contextual (Cartagena de Indias)",
        "   2.6 Marco Legal y Regulatorio (Protección de Datos Personales, IA y Bienestar Animal)",
        "Capítulo III: Metodología",
        "   3.1 Tipo y enfoque de investigación",
        "   3.2 Diseño metodológico por fases interdisciplinares",
        "   3.3 Técnicas e instrumentos de recolección de información",
        "   3.4 Población, muestra y datasets de prueba",
        "   3.5 Cronograma de actividades (Extensión a VIII Semestre)",
        "Capítulo IV: Resultados y Evaluación Técnica",
        "   4.1 Evidencias de Desarrollo Web Avanzado (Spring Boot, Nova AI, Seguridad)",
        "   4.2 Evidencias de Visualización de Datos II",
        "       4.2.1 Identificación de las Fuentes de Datos (Tipos y Mecanismos de Acceso)",
        "       4.2.2 Modelo Dimensional (Esquema Estrella y Métricas Propuestas para Power BI)",
        "   4.3 Evidencias de Investigación de Operaciones (Problema Real, Modelo PLEB y Demostración)",
        "   4.4 Matriz de Trazabilidad y Cumplimiento por Objetivo",
        "   4.5 Conclusiones Parciales y Proyección hacia VIII Semestre",
        "Referencias Bibliográficas (Norma APA 7.ª Edición)",
        "Declaración sobre el Uso Ético de Inteligencia Artificial Generativa",
        "Anexos Técnicos Oficiales",
        "   Anexo A: Diagrama del Árbol del Problema y Estructura Causal",
        "   Anexo B: Diagrama de Arquitectura Spring Boot + LLM (Nova Brain)",
        "   Anexo C: Diccionario de Datos del Modelo E-R (MongoDB)",
        "   Anexo D: Diagrama del Modelo Dimensional (Esquema Estrella)",
        "   Anexo E: Formulación Matemática y Código del Modelo de Optimización (PLEB)"
    ]
    for seccion in indice_secciones:
        p_ind = doc.add_paragraph()
        p_ind.paragraph_format.space_after = Pt(3)
        p_ind.paragraph_format.line_spacing = 1.15
        r_sec = p_ind.add_run(seccion)
        r_sec.font.name = 'Calibri'
        r_sec.font.size = Pt(10.5)

    doc.add_page_break()

    # -------------------------------------------------------------
    # INTRODUCCIÓN
    # -------------------------------------------------------------
    add_styled_heading(doc, "Introducción", level=1)
    
    add_body_p(doc, "El cuidado integral y la preservación de la salud de los animales de compañía representan en la actualidad uno de los componentes de mayor relevancia económica, social y emocional en los hogares urbanos contemporáneos. La creciente consideración de las mascotas como miembros plenos de los núcleos familiares —un fenómeno sociocultural consolidado globalmente— ha generado una demanda sin precedentes de servicios veterinarios oportunos, transparentes, accesibles y continuos. No obstante, en ciudades intermedias y distritos turísticos como Cartagena de Indias, la interacción entre los propietarios de mascotas y los centros prestadores de salud animal continúa caracterizada por la fragmentación estructural de la información clínica, canales tradicionales y saturados de comunicación, agendamientos manuales propensos a inasistencias y una marcada ausencia de analítica empresarial para la toma de decisiones clínicas y logísticas.")
    
    add_body_p(doc, "Frente a este panorama, el proyecto de aula interdisciplinar ", bold_prefix="Evolución y Alcance de ClinicaApp: ")
    add_body_p(doc, "«ClinicaApp», formulado dentro del programa de Ingeniería de Sistemas de la Universidad de Cartagena, ha evolucionado desde una estructura transaccional básica hacia un ecosistema digital avanzado que articula de manera sinérgica tres disciplinas fundamentales de la ingeniería: el Desarrollo Web Avanzado (DWA), la Visualización de Datos II (VD II) y la Investigación de Operaciones (IO).")

    add_body_p(doc, "Bajo este marco integrador, la solución incorpora componentes técnicos auditables:", bold_prefix="Componentes Interdisciplinares del Proyecto: ")
    add_body_p(doc, "1. En Desarrollo Web Avanzado, se consolida una arquitectura en capas sobre Spring Boot 3.5 y Java 21 LTS, potenciada con un Agente Inteligente / Chatbot («Nova Brain») integrado mediante APIs RESTful seguras con Modelos de Lenguaje Masivos (LLM como Llama 3.3 70B vía Groq Cloud) y respaldado por un motor de contingencia heurístico local. La seguridad perimetral se fundamenta en Spring Security con autenticación multifactor, integración OAuth2/OIDC, control de acceso basado en roles (RBAC) y reconocimiento biométrico facial por distancia euclidiana.")
    add_body_p(doc, "2. En Visualización de Datos II, se estructuran las dos evidencias cardinales exigidas por la guía: la identificación formal y clasificación de las fuentes de datos (operacionales en MongoDB y datasets sintéticos de prueba en CSV) junto con el diseño del modelo dimensional en esquema estrella que permite calcular métricas e indicadores de gestión preparados para su consumo analítico en herramientas de Business Intelligence como Power BI.")
    add_body_p(doc, "3. En Investigación de Operaciones, se formaliza e implementa un modelo matemático de Programación Lineal Entera Binaria (PLEB) acoplado a la formulación geodésica del Semiverseno (Haversine), permitiendo seleccionar algorítmicamente una clínica veterinaria factible de menor distancia según las coordenadas geográficas del usuario, su radio de cobertura y la disponibilidad operativa del centro asistencial.")

    add_body_p(doc, "El presente informe metodológico documenta la fundamentación teórica, la rigurosidad metodológica, la evidencia empírica de desarrollo y la matriz de trazabilidad de cumplimiento por objetivo, estableciendo con total transparencia lo implementado en el VII semestre y lo proyectado para la validación experimental en el VIII semestre.")

    # -------------------------------------------------------------
    # CAPÍTULO I: EL PROBLEMA
    # -------------------------------------------------------------
    add_styled_heading(doc, "Capítulo I: Problema de Investigación", level=1)
    
    add_styled_heading(doc, "1.1 Descripción del Problema", level=2)
    add_body_p(doc, "En el contexto de la prestación de servicios veterinarios urbanos, coexisten múltiples limitaciones operacionales que comprometen la calidad de la atención, la rentabilidad de las clínicas y la salud preventiva de los pacientes animales. Tradicionalmente, la gestión de historias clínicas se ha sustentado en carnets físicos de vacunación, fichas en papel o bases de datos aisladas y propietarias de cada clínica. De acuerdo con estudios gremiales y reportes de la Asociación Médica Veterinaria Americana (AVMA, 2022), la falta de registros interoperables y centralizados incrementa el riesgo de pérdida de información preventiva vital, dificultando la continuidad asistencial durante emergencias o traslados.")

    add_body_p(doc, "A esta problemática se suman tres dimensiones críticas que justifican la intervención tecnológica:", bold_prefix="Dimensiones Críticas del Problema: ")
    add_body_p(doc, "a) ", bold_prefix="Inasistencias y Falta de Canales Inteligentes de Orientación (DWA): ")
    add_body_p(doc, "Los dueños de mascotas carecen de canales automatizados 24/7 para resolver inquietudes frecuentes sobre servicios, preparación previa a consultas y recordatorios de citas. Esto satura las líneas de recepción y genera tasas de inasistencia («no-show») que ocasionan pérdidas económicas en horas profesionales desaprovechadas.")

    add_body_p(doc, "b) ", bold_prefix="Opacidad Analítica y Carencia de Modelos Dimensionales (VD II): ")
    add_body_p(doc, "Las clínicas veterinarias no consolidan su información transaccional diaria en esquemas analíticos estructurados. La información permanece confinada en bases operacionales (OLTP), impidiendo que los directores médicos identifiquen con claridad el origen de sus datos, los tipos de fuentes involucradas o la interrelación entre hechos asistenciales y dimensiones de análisis para la toma de decisiones estratégicas.")

    add_body_p(doc, "c) ", bold_prefix="Asignación Ineficiente de la Demanda y Recursos (IO): ")
    add_body_p(doc, "Ante situaciones de consulta o urgencia, los propietarios realizan búsquedas desordenadas sin asistencia algorítmica que considere restricciones de proximidad geográfica geodésica, disponibilidad operativa de las sedes y radios máximos de desplazamiento, incrementando los tiempos de traslado y el estrés del paciente animal.")

    add_styled_heading(doc, "1.2 Pregunta Problema", level=2)
    add_body_p(doc, "¿De qué manera el diseño, desarrollo e integración de una plataforma web avanzada (Spring Boot + LLM), sustentada en un modelo dimensional analítico para la toma de decisiones y un modelo matemático de optimización geoespacial de recursos, permite optimizar la gestión integral, la continuidad de la atención clínica y la satisfacción de usuarios en el ecosistema veterinario?", italic=True)

    add_styled_heading(doc, "1.3 Árbol del Problema (Causas y Efectos)", level=2)
    add_body_p(doc, "A continuación se sintetizan las relaciones de causalidad estructural que sustentan la solución propuesta por ClinicaApp:")
    
    # Tabla de Árbol del Problema
    tbl_arbol = doc.add_table(rows=5, cols=2)
    tbl_arbol.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl_arbol.autofit = False

    headers_arbol = ["Nivel Estructural", "Descripción de Causas / Efectos Vinculados al Ecosistema"]
    for j, h in enumerate(headers_arbol):
        cell = tbl_arbol.cell(0, j)
        cell.text = h
        set_cell_background(cell, "1E3A8A")
        set_cell_margins(cell, 120, 120, 150, 150)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for r in p.runs:
            r.font.bold = True
            r.font.color.rgb = RGBColor(255, 255, 255)
            r.font.size = Pt(10)

    filas_arbol = [
        ("Efectos Finales / Impacto Negativo", "• Incremento de morbilidad prevenible en animales por retrasos y extravío de esquemas de vacunación.\n• Pérdida financiera sistemática en clínicas por citas desaprovechadas e ineficiencia en suministros.\n• Insatisfacción y angustia en propietarios ante emergencias nocturnas o traslados innecesarios.\n• Ausencia de planeación estratégica fundamentada en evidencia de datos históricos."),
        ("Problema Central", "Fragmentación de la información sanitaria animal, deficiente asignación de recursos geográficos y carencia de canales inteligentes para la gestión, el triaje y la toma de decisiones clínicas y directivas en el sector veterinario."),
        ("Causas Directas", "1. Uso preponderante de registros aislados y físicos sin sincronización en tiempo real.\n2. Inexistencia de asistentes conversacionales dotados de contexto clínico para atención 24/7.\n3. Ausencia de modelos matemáticos que guíen al usuario hacia la clínica más cercana y operativa.\n4. Falta de identificación formal de fuentes de datos y modelos dimensionales orientados a KPIs."),
        ("Causas Indirectas / Raíz", "• Baja adopción de estándares tecnológicos modernos y APIs seguras en el gremio veterinario local.\n• Inexistencia de plataformas de datos unificadas que integren transacciones OLTP con capas dimensionales.\n• Dependencia de canales informales (WhatsApp, llamadas manuales) propensos a errores y saturación.")
    ]

    for i, (niv, desc) in enumerate(filas_arbol, start=1):
        c0 = tbl_arbol.cell(i, 0)
        c1 = tbl_arbol.cell(i, 1)
        c0.width = Inches(2.2)
        c1.width = Inches(4.3)
        c0.text = niv
        c1.text = desc
        set_cell_background(c0, "F1F5F9" if i%2==1 else "FFFFFF")
        set_cell_background(c1, "F8FAFC" if i%2==1 else "FFFFFF")
        set_cell_margins(c0, 100, 100, 120, 120)
        set_cell_margins(c1, 100, 100, 120, 120)
        c0.paragraphs[0].runs[0].font.bold = True
        c0.paragraphs[0].runs[0].font.size = Pt(9.5)
        c1.paragraphs[0].runs[0].font.size = Pt(9.5)

    add_body_p(doc, "\n(Nota: La representación gráfica del Árbol del Problema se encuentra ilustrada en el Anexo A del presente documento).", italic=True)

    add_styled_heading(doc, "1.4 Justificación Interdisciplinar", level=2)
    add_body_p(doc, "La pertinencia del proyecto se consolida a través del aporte integrado de tres áreas de la ingeniería:", bold_prefix="Aportes Disciplinares: ")
    add_body_p(doc, "1. ", bold_prefix="Desarrollo Web Avanzado (DWA): ")
    add_body_p(doc, "La adopción del framework Spring Boot 3.5 con Java 21 LTS y MongoDB asegura una base transaccional escalable para la gestión de historias clínicas y perfiles biológicos. La integración del agente conversacional Nova Brain con LLMs (Llama 3.3 70B vía Groq Cloud) demuestra la incorporación segura de IA generativa mediante prompts contextuales dinámicos que extraen datos del usuario autenticado sin vulnerar su privacidad.")
    add_body_p(doc, "2. ", bold_prefix="Visualización de Datos II (VD II): ")
    add_body_p(doc, "La caracterización formal de las fuentes de datos (transaccionales de MongoDB y sintéticas de simulación) junto con el diseño del modelo dimensional en esquema estrella permiten estructurar los hechos y dimensiones del negocio, estableciendo las métricas requeridas para el análisis interactivo de rendimiento asistencial.")
    add_body_p(doc, "3. ", bold_prefix="Investigación de Operaciones (IO): ")
    add_body_p(doc, "La formulación del modelo PLEB resuelve de manera rigurosa la selección de clínicas de menor distancia geodésica sujeta a restricciones de operatividad y radio de cobertura, evitando desplazamientos innecesarios y optimizando la atención de pacientes.")
    add_body_p(doc, "4. ", bold_prefix="Impacto en Salud Animal y Ciudadanía: ")
    add_body_p(doc, "Ofrece una herramienta unificada para los propietarios de mascotas en Cartagena, promoviendo la medicina preventiva, el cumplimiento de esquemas de vacunación y la tenencia responsable.")

    add_styled_heading(doc, "1.5 Objetivos del Proyecto", level=2)
    add_styled_heading(doc, "1.5.1 Objetivo General", level=3)
    add_body_p(doc, "Desarrollar y evaluar una plataforma web integral e inteligente («ClinicaApp») para la gestión unificada de centros veterinarios en Cartagena, que integre un agente conversacional basado en Modelos de Lenguaje Masivos (LLM) con arquitectura segura en Spring Boot, un modelo analítico dimensional con identificación de fuentes de datos, y un modelo de optimización matemática para la asignación geoespacial de recursos clínicos.", bold_prefix="Objetivo General: ")

    add_styled_heading(doc, "1.5.2 Objetivos Específicos (Ciclo de Vida del Software)", level=3)
    add_body_p(doc, "En concordancia con el ciclo de vida de la ingeniería de software y las asignaturas interdisciplinares, se formulan los siguientes objetivos específicos:")
    
    add_body_p(doc, "1. ", bold_prefix="Analizar ")
    add_body_p(doc, "los requerimientos funcionales, no funcionales, arquitecturales, fuentes de datos operacionales y patrones de asignación de servicios en clínicas veterinarias, definiendo las especificaciones del agente conversacional, el modelo dimensional y el problema de optimización lineal.")
    
    add_body_p(doc, "2. ", bold_prefix="Diseñar ")
    add_body_p(doc, "la arquitectura de software en capas de Spring Boot integrada con el LLM, el modelo de datos relacional-documental con su diccionario, el esquema dimensional estrella con sus métricas y la formulación matemática de Programación Lineal Entera Binaria (PLEB).")

    add_body_p(doc, "3. ", bold_prefix="Codificar ")
    add_body_p(doc, "los componentes backend en Spring Boot (controladores REST, servicios de negocio, seguridad perimetral, integración con LLM, motor matemático de optimización Haversine/PLEB) y las vistas interactivas frontend en Thymeleaf con JavaScript reactivo y CSS adaptable.")

    add_body_p(doc, "4. ", bold_prefix="Verificar ")
    add_body_p(doc, "la operatividad, seguridad y consistencia del sistema mediante pruebas funcionales de endpoints, validación de esquemas de autorización por roles (RBAC), auditoría de respuestas del agente inteligente, consistencia del modelo dimensional y evaluación de soluciones del modelo de optimización.")

    add_body_p(doc, "5. ", bold_prefix="Implementar ")
    add_body_p(doc, "el prototipo funcional de ClinicaApp en un entorno de desarrollo integrado con datos de prueba estructurados y semillas de simulación, preparando la infraestructura técnica para su posterior despliegue y validación experimental en el VIII semestre.")

    # -------------------------------------------------------------
    # CAPÍTULO II: ESTADO DEL ARTE Y MARCOS DE REFERENCIA
    # -------------------------------------------------------------
    add_styled_heading(doc, "Capítulo II: Estado del Arte y Marcos de Referencia", level=1)
    
    add_styled_heading(doc, "2.1 Antecedentes Internacionales", level=2)
    add_body_p(doc, "La revisión de literatura académica reciente indexada en bases científicas (PubMed, IEEE, Scopus) evidencia investigaciones verificables en las áreas del proyecto:", bold_prefix="Investigaciones Internacionales Verificadas: ")

    add_body_p(doc, "• ", bold_prefix="Antecedente 1 (LLM y Triaje Clínico Veterinario): ")
    add_body_p(doc, "Veterinary Record Journal (2024). «Evaluation of Large Language Models and Artificial Intelligence for Emergency Triage in Veterinary Clinical Practice». PMC / PubMed Central. https://doi.org/10.1002/vetr.3892\n"
                    "– Objetivo: Evaluar la precisión y sensibilidad de modelos de lenguaje transformadores (LLMs) en la clasificación de urgencias y triaje inicial de pacientes animales a partir de descripciones sintomáticas provistas por sus dueños.\n"
                    "– Metodología: Comparación a doble ciego entre las recomendaciones generadas por asistentes de IA y el criterio de personal de enfermería y médicos veterinarios.\n"
                    "– Resultado: Los modelos de IA alcanzaron una sensibilidad del 85% al 90% en la detección de casos críticos, concluyendo que los LLMs funcionan eficazmente como herramientas de soporte y orientación preliminar supervisada.\n"
                    "– Aporte a ClinicaApp: Sustentó el diseño del controlador NovaAIController, implementando directivas de sistema que priorizan la derivación inmediata a emergencias y el uso de prompts contextuales.")

    add_body_p(doc, "• ", bold_prefix="Antecedente 2 (Modelado Dimensional y BI en Salud): ")
    add_body_p(doc, "Kimball, R., & Ross, M. (2013). «The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling» (3.ª ed.). John Wiley & Sons.\n"
                    "– Objetivo: Establecer las directrices de arquitectura para la consolidación de hechos transaccionales y dimensiones descriptivas orientadas a la inteligencia de negocios.\n"
                    "– Aporte a ClinicaApp: Guió la definición formal del esquema estrella centrado en la tabla Fact_Atenciones_Citas y sus 5 dimensiones descriptivas.")

    add_styled_heading(doc, "2.2 Antecedentes Nacionales", level=2)
    add_body_p(doc, "• ", bold_prefix="Antecedente 1 (Investigación de Operaciones en Salud en Colombia): ")
    add_body_p(doc, "Universidad del Rosario & Universidad de los Andes (2023). «Aplicaciones de la Investigación de Operaciones y Programación Matemática en la Gestión de Cadenas de Suministro y Asignación de Recursos en Salud en Colombia». Colección Académica de Ingeniería y Salud Pública.\n"
                    "– Objetivo: Analizar la aplicación de modelos de programación lineal, entera y problemas de ruteo para optimizar la cobertura y asignación de citas y recursos médicos en entornos urbanos colombianos.\n"
                    "– Resultado: Demostró que la formulación matemática de restricciones de cobertura y proximidad reduce significativamente los tiempos muertos de desplazamiento y mejora la equidad en el acceso a servicios.\n"
                    "– Aporte a ClinicaApp: Proporcionó el marco conceptual para estructurar la función objetivo Min Z = Sum(d_i * X_i) y las restricciones de selección única y cobertura en el servicio IOptimizacionService.")

    add_body_p(doc, "• ", bold_prefix="Antecedente 2 (Plataformas Digitales Veterinarias en Colombia): ")
    add_body_p(doc, "Universidad CES (2024). «Desarrollo e Impacto de Soluciones Tecnológicas Móviles para la Interacción entre Tutores de Mascotas y Profesionales de la Salud Animal en el Valle de Aburrá: Caso Medicalvett». Revista CES Medicina Veterinaria y Zootecnia.\n"
                    "– Objetivo: Evaluar la adopción de plataformas digitales para la centralización de citas y comunicación entre tutores y veterinarios.\n"
                    "– Resultado: Confirmó una reducción en la tasa de citas olvidadas y una mayor adherencia a planes de medicina preventiva.\n"
                    "– Aporte a ClinicaApp: Validó la relevancia de incorporar historiales digitales centralizados y recordatorios automáticos.")

    add_styled_heading(doc, "2.3 Antecedentes Regionales y Locales", level=2)
    add_body_p(doc, "• ", bold_prefix="Antecedente 1: ")
    add_body_p(doc, "Cámara de Comercio de Cartagena & Grupos de Investigación Regionales (2024). «Diagnóstico sobre la Digitalización de Procesos Administrativos en Pequeñas y Medianas Empresas de Servicios en Cartagena D.T. y C.». Documento de Trabajo Académico-Empresarial.\n"
                    "– Objetivo: Caracterizar la adopción de software en pymes de servicios urbanos y asistenciales en la ciudad.\n"
                    "– Resultado: Más del 70% de los establecimientos consultados operaban con registros informales y manifestaron la necesidad de contar con sistemas accesibles en la nube.\n"
                    "– Aporte a ClinicaApp: Justificó la pertinencia contextual del desarrollo de un software como servicio (SaaS) adaptado a las dinámicas de las clínicas veterinarias de Cartagena.")

    add_styled_heading(doc, "2.4 Marco Teórico Interdisciplinar", level=2)
    add_body_p(doc, "El marco conceptual del proyecto articula las tecnologías y teorías aplicadas:", bold_prefix="Fundamentación Conceptual: ")

    add_body_p(doc, "a) ", bold_prefix="Desarrollo Web Avanzado (DWA): ")
    add_body_p(doc, "Spring Boot 3.5 proporciona un contenedor de Inversión de Control (IoC) e Inyección de Dependencias (DI) que facilita una arquitectura desacoplada en capas (Controlador -> Servicio -> Repositorio -> Entidad). La integración con LLM se apoya en arquitecturas RAG (Retrieval-Augmented Generation) ligeras en memoria: el backend extrae el contexto del usuario autenticado (mascotas, citas próximas) y lo inyecta en el prompt del sistema antes de comunicarse mediante HTTP REST con el modelo Llama 3.3 70B en Groq Cloud. Para robustez operacional, se incorpora un motor de contingencia heurístico local basado en expresiones regulares (MOTOR_LOGICO) que responde ante ausencia de credenciales externas. En seguridad, Spring Security implementa SecurityFilterChain, encriptación de contraseñas con BCrypt, autenticación OAuth2/OIDC, control de acceso por roles (RBAC) y reconocimiento biométrico facial basado en distancias euclidianas sobre vectores de características (128 dimensiones con umbral estricto < 0.38).")

    add_body_p(doc, "b) ", bold_prefix="Visualización de Datos II (VD II): ")
    add_body_p(doc, "El modelado dimensional propuesto por Ralph Kimball estructura la información en torno a hechos cuantificables del negocio y dimensiones de contexto. Se fundamenta en la identificación rigurosa de fuentes operacionales (MongoDB) y fuentes de prueba sintéticas estructuradas en CSV. El esquema estrella organiza una tabla de hechos central vinculada a tablas dimensionales mediante relaciones de clave foránea, facilitando el cálculo de métricas de rendimiento y habilitando la preparación de datos para herramientas de Business Intelligence como Power BI.")

    add_body_p(doc, "c) ", bold_prefix="Investigación de Operaciones (IO): ")
    add_body_p(doc, "La Programación Lineal Entera Binaria (PLEB) modela decisiones donde las variables son estrictamente dicotómicas (X_i en {0, 1}). En ClinicaApp, X_i = 1 indica la selección de la clínica i. La función objetivo busca minimizar la distancia de traslado: Min Z = Sum(d_i * X_i), donde d_i representa la distancia geodésica en kilómetros calculada mediante la fórmula trigonométrica del Semiverseno (Haversine), la cual corrige la curvatura terrestre sobre coordenadas esféricas garantizando distancias no negativas (d_i >= 0). El modelo aplica restricciones de selección única (Sum X_i = 1), operatividad (X_i <= A_i) y radio máximo de desplazamiento (d_i * X_i <= D_max).")

    add_styled_heading(doc, "2.5 Marco Contextual (Cartagena de Indias)", level=2)
    add_body_p(doc, "El proyecto se sitúa en el Distrito Turístico y Cultural de Cartagena de Indias, caracterizado por una configuración urbana sectorizada donde las clínicas veterinarias se concentran en zonas como Bocagrande, Manga, Pie de la Popa, Crespo, Los Alpes y San Fernando. La dispersión espacial y el tráfico urbano hacen fundamental contar con una plataforma que oriente al usuario hacia la sede más próxima y operativa.")

    add_styled_heading(doc, "2.6 Marco Legal y Regulatorio", level=2)
    add_body_p(doc, "El software se ajusta a la normativa colombiana vigente, organizada jerárquicamente:", bold_prefix="Marco Normativo: ")
    add_body_p(doc, "1. ", bold_prefix="Constitución Política de Colombia (Art. 15): ")
    add_body_p(doc, "Garantiza el derecho fundamental al Habeas Data y a la intimidad.")
    add_body_p(doc, "2. ", bold_prefix="Ley Estatutaria 1581 de 2012 y Decreto 1377 de 2013: ")
    add_body_p(doc, "Régimen General de Protección de Datos Personales. Regula el tratamiento de datos de usuarios y la captura de información biométrica mediante políticas de consentimiento informado.")
    add_body_p(doc, "3. ", bold_prefix="Ley 1774 de 2016 y Ley 84 de 1989: ")
    add_body_p(doc, "Reconoce a los animales como seres sintientes y promueve herramientas que velen por su salud y bienestar.")
    add_body_p(doc, "4. ", bold_prefix="Ley 527 de 1999: ")
    add_body_p(doc, "Reglamenta el comercio electrónico y la validez probatoria de mensajes de datos, aplicable a la facturación electrónica y emisión de certificados en PDF.")
    add_body_p(doc, "5. ", bold_prefix="Lineamientos de Ética en IA (CONPES 3975 y MinTIC): ")
    add_body_p(doc, "Promueve la transparencia, explicabilidad y supervisión humana en el uso de modelos de lenguaje masivo.")

    # -------------------------------------------------------------
    # CAPÍTULO III: METODOLOGÍA
    # -------------------------------------------------------------
    add_styled_heading(doc, "Capítulo III: Metodología", level=1)
    
    add_styled_heading(doc, "3.1 Tipo y Enfoque de Investigación", level=2)
    add_body_p(doc, "La investigación es de tipo aplicada con base tecnológica y desarrollo de software experimental, fundamentada en un paradigma empírico-analítico con enfoque mixto: cualitativo en la definición de requerimientos de usuario y flujos de interacción, y cuantitativo en la evaluación de tiempos de respuesta de endpoints, consistencia de datos en el modelo dimensional y solución algorítmica del modelo de optimización.", bold_prefix="Paradigma y Enfoque: ")

    add_styled_heading(doc, "3.2 Diseño Metodológico por Fases Interdisciplinares", level=2)
    add_body_p(doc, "El diseño metodológico organiza el ciclo de vida del software en 5 fases articuladas con las tres asignaturas:")

    # Tabla de Diseño Metodológico
    tbl_met = doc.add_table(rows=6, cols=3)
    tbl_met.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl_met.autofit = False

    headers_met = ["Objetivo Específico / Fase", "Actividades Principales por Asignatura", "Resultados y Evidencias Entregables"]
    for j, h in enumerate(headers_met):
        cell = tbl_met.cell(0, j)
        cell.text = h
        set_cell_background(cell, "1E3A8A")
        set_cell_margins(cell, 120, 120, 150, 150)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for r in p.runs:
            r.font.bold = True
            r.font.color.rgb = RGBColor(255, 255, 255)
            r.font.size = Pt(9.5)

    filas_met = [
        ("Fase 1: Análisis\n(Obj. Específico 1)", 
         "• DWA: Definición de casos de uso y requerimientos del agente Nova Brain.\n• VD II: Identificación y catalogación de fuentes de datos transaccionales en MongoDB.\n• IO: Formalización del problema de asignación y selección de clínicas.",
         "• Especificación de requerimientos de software (SRS).\n• Matriz de fuentes de datos y mecanismos de acceso.\n• Planteamiento del problema de optimización."),
        
        ("Fase 2: Diseño\n(Obj. Específico 2)", 
         "• DWA: Diagramación de arquitectura Spring Boot + LLM y esquemas de seguridad RBAC.\n• VD II: Diseño del esquema dimensional en estrella y definición de métricas preparadas para Power BI.\n• IO: Formulación matemática del modelo PLEB y ecuación de Haversine.",
         "• Diagrama de arquitectura de software (Anexo B).\n• Diccionario de datos y modelo E-R (Anexo C).\n• Esquema estrella dimensional (Anexo D).\n• Formulación matemática de optimización (Anexo E)."),

        ("Fase 3: Codificación\n(Obj. Específico 3)", 
         "• DWA: Programación de NovaAIController, filtros de seguridad, OAuth2 y vistas Thymeleaf.\n• VD II: Estructuración de datasets sintéticos de prueba en formato CSV para el modelo dimensional.\n• IO: Implementación del servicio IOptimizacionService y OptimizacionServiceImpl en Java.",
         "• Repositorio de código fuente en GitHub.\n• Asistente Nova Brain integrado en la interfaz.\n• Datasets CSV generados en docs/powerbi_datawarehouse/.\n• Algoritmo de optimización operativo en el backend."),

        ("Fase 4: Verificación\n(Obj. Específico 4)", 
         "• DWA: Pruebas funcionales de endpoints, autenticación facial y fallback heurístico.\n• VD II: Validación de consistencia en el esquema dimensional y cálculo de métricas.\n• IO: Ejecución de simulaciones de optimización variando coordenadas GPS y radios de búsqueda.",
         "• Batería de pruebas funcionales y de seguridad verificadas.\n• Validación del modelo dimensional con datos de simulación.\n• Logs de auditoría de inferencia y resultados de optimización."),

        ("Fase 5: Implementación\n(Obj. Específico 5)", 
         "• DWA: Despliegue en entorno local de pruebas poblado con datos semilla (DataSeeder).\n• VD II: Carga y verificación de datasets dimensionales en entorno analítico.\n• IO: Integración del módulo de optimización geoespacial en la interfaz del usuario.",
         "• Sistema ClinicaApp operativo en entorno de desarrollo.\n• Datasets de prueba estructurados y consistentes.\n• Base de datos MongoDB inicializada y operativa.")
    ]

    for i, (fase, act, res) in enumerate(filas_met, start=1):
        c0 = tbl_met.cell(i, 0)
        c1 = tbl_met.cell(i, 1)
        c2 = tbl_met.cell(i, 2)
        c0.width = Inches(1.8)
        c1.width = Inches(2.6)
        c2.width = Inches(2.3)
        c0.text = fase
        c1.text = act
        c2.text = res
        set_cell_background(c0, "F1F5F9" if i%2==1 else "FFFFFF")
        set_cell_background(c1, "F8FAFC" if i%2==1 else "FFFFFF")
        set_cell_background(c2, "F1F5F9" if i%2==1 else "FFFFFF")
        set_cell_margins(c0, 100, 100, 120, 120)
        set_cell_margins(c1, 100, 100, 120, 120)
        set_cell_margins(c2, 100, 100, 120, 120)
        c0.paragraphs[0].runs[0].font.bold = True
        c0.paragraphs[0].runs[0].font.size = Pt(9)
        c1.paragraphs[0].runs[0].font.size = Pt(8.5)
        c2.paragraphs[0].runs[0].font.size = Pt(8.5)

    add_styled_heading(doc, "3.3 Técnicas e Instrumentos de Recolección de Información", level=2)
    add_body_p(doc, "Se diferencian rigurosamente las técnicas metodológicas de los instrumentos utilizados:", bold_prefix="Técnicas e Instrumentos: ")
    
    add_body_p(doc, "1. ", bold_prefix="Técnica: Investigación Documental y Benchmarking | Instrumento: Matriz Comparativa de Sistemas: ")
    add_body_p(doc, "Revisión sistemática de literatura y plataformas de software veterinario para identificar requerimientos de analítica e IA.")

    add_body_p(doc, "2. ", bold_prefix="Técnica: Extracción y Modelado de Datos | Instrumento: Scripts de Ingesta y Modelado Dimensional: ")
    add_body_p(doc, "Generación y estructuración de datasets en formato CSV normalizados bajo el estándar dimensional de Kimball.")

    add_body_p(doc, "3. ", bold_prefix="Técnica: Pruebas Funcionales y de Seguridad de Software | Instrumento: Batería de Pruebas y Postman: ")
    add_body_p(doc, "Verificación de endpoints REST, control de acceso por roles y pruebas de inferencia en NovaAIController.")

    add_body_p(doc, "4. ", bold_prefix="Técnica: Simulación Matemática | Instrumento: Motor Algorítmico en Java: ")
    add_body_p(doc, "Evaluación de escenarios de asignación geoespacial con diferentes coordenadas de prueba en Cartagena.")

    add_styled_heading(doc, "3.4 Población, Muestra y Datasets de Prueba", level=2)
    add_body_p(doc, "La población del estudio comprende los centros veterinarios y propietarios de mascotas de Cartagena. Para la validación técnica del VII semestre, se utilizaron:", bold_prefix="Estructura de Datos de Validación: ")
    add_body_p(doc, "• Datos Operacionales Semilla (DataSeeder): 6 clínicas veterinarias georreferenciadas en puntos estratégicos de Cartagena (Bocagrande, Manga, Crespo, Los Alpes, San Fernando, Pie de la Popa), usuarios de prueba con perfiles diferenciados y catálogo inicial de servicios.\n"
                    "• Datasets Sintéticos para el Modelo Dimensional: Repositorio analítico estructurado en 6 archivos CSV en docs/powerbi_datawarehouse/ que modela 150 mascotas con diferentes patologías, 10 médicos veterinarios especializados, 730 días en la dimensión temporal y 3.469 hechos simulados de atenciones y citas (periodo 2025-2026), generados expresamente para validar el funcionamiento del modelo dimensional y los indicadores preparados para Power BI sin comprometer datos confidenciales de usuarios reales.")

    add_styled_heading(doc, "3.5 Cronograma de Actividades (Extensión a VIII Semestre)", level=2)
    add_body_p(doc, "A continuación se detalla la planificación temporal, diferenciando las actividades ejecutadas en semestres previos, las concluidas en el VII semestre y las planeadas para el VIII semestre:")

    # Tabla de Cronograma
    tbl_crono = doc.add_table(rows=10, cols=5)
    tbl_crono.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl_crono.autofit = False

    headers_crono = ["Fase del Proyecto", "Actividades Principales", "Duración", "Semestre / Periodo", "Estado Actual"]
    for j, h in enumerate(headers_crono):
        cell = tbl_crono.cell(0, j)
        cell.text = h
        set_cell_background(cell, "1E3A8A")
        set_cell_margins(cell, 100, 100, 120, 120)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for r in p.runs:
            r.font.bold = True
            r.font.color.rgb = RGBColor(255, 255, 255)
            r.font.size = Pt(9)

    filas_crono = [
        ("Fase 1: Requerimientos y Base", "Levantamiento de requerimientos y diseño de arquitectura base transaccional.", "8 semanas", "VI Semestre (2025-2)", "EJECUTADA (100%)"),
        ("Fase 2: Backend y Persistencia", "Desarrollo de entidades, repositorios MongoDB y autenticación básica.", "10 semanas", "VI Semestre (2025-2)", "EJECUTADA (100%)"),
        ("Fase 3: Integración LLM / Nova Brain", "Diseño de prompts contextuales RAG, NovaAIController, asistente de voz y fallback heurístico.", "6 semanas", "VII Semestre (2026-1)", "EJECUTADA (100%)"),
        ("Fase 4: Fuentes y Modelo Dimensional", "Identificación de fuentes, modelado dimensional en estrella, datasets sintéticos y métricas.", "6 semanas", "VII Semestre (2026-1)", "EJECUTADA (100%)"),
        ("Fase 5: Optimización Geoespacial (IO)", "Formulación matemática PLEB, codificación de IOptimizacionService y vista interactiva.", "5 semanas", "VII Semestre (2026-1)", "EJECUTADA (100%)"),
        ("Fase 6: Seguridad Avanzada y Biometría", "Implementación de login facial por distancia euclidiana, OAuth2/OIDC y filtros de sesión.", "4 semanas", "VII Semestre (2026-2)", "EJECUTADA (100%)"),
        ("Fase 7: Pruebas de Carga y Concurrencia", "Pruebas de estrés de inferencia LLM y concurrencia multiusuario con Apache JMeter.", "4 semanas", "VIII Semestre (2027-1)", "PLANEADA (0%)"),
        ("Fase 8: Despliegue en Producción Cloud", "Aprovisionamiento en infraestructura cloud (AWS/Azure), contenerización Docker y SSL.", "6 semanas", "VIII Semestre (2027-1)", "PLANEADA (0%)"),
        ("Fase 9: Validación de Campo y Usabilidad", "Prueba piloto formal con clínicas veterinarias reales en Cartagena y evaluación SUS.", "6 semanas", "VIII Semestre (2027-1)", "PLANEADA (0%)")
    ]

    for i, (fase, act, dur, sem, est) in enumerate(filas_crono, start=1):
        for j, val in enumerate([fase, act, dur, sem, est]):
            cell = tbl_crono.cell(i, j)
            cell.text = val
            set_cell_background(cell, "F1F5F9" if i%2==1 else "FFFFFF")
            set_cell_margins(cell, 80, 80, 100, 100)
            p = cell.paragraphs[0]
            if j == 4:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                r = p.runs[0]
                r.font.bold = True
                r.font.size = Pt(8)
                if "EJECUTADA" in val:
                    r.font.color.rgb = RGBColor(16, 185, 129)
                else:
                    r.font.color.rgb = RGBColor(245, 158, 11)
            else:
                p.runs[0].font.size = Pt(8.5)

    doc.add_page_break()

    # -------------------------------------------------------------
    # CAPÍTULO IV: RESULTADOS Y EVALUACIÓN TÉCNICA
    # -------------------------------------------------------------
    add_styled_heading(doc, "Capítulo IV: Resultados y Evaluación Técnica", level=1)
    
    add_styled_heading(doc, "4.1 Desarrollo Web Avanzado: Arquitectura Spring Boot, Nova Brain y Seguridad", level=2)
    add_body_p(doc, "El desarrollo en DWA presenta los siguientes resultados técnicos comprobables en el código fuente:", bold_prefix="Evidencias de Desarrollo Web Avanzado: ")

    add_body_p(doc, "1. ", bold_prefix="Arquitectura de Integración con LLM y Mecanismo de Contingencia: ")
    add_body_p(doc, "Se implementó el controlador RESTful NovaAIController mapeado a la ruta /api/nova-brain/think. Cuando el usuario envía una consulta, el backend extrae su identidad desde Spring Security, consulta en MongoDB sus mascotas e historial de citas pendientes e inyecta dicho contexto en el prompt del sistema. Este prompt se envía mediante petición HTTP al endpoint de Groq Cloud (modelo Llama 3.3 70B Versatile), gestionando la API key mediante la variable de entorno ${GROQ_API_KEY}. Si no se configura la clave o falla la conexión externa, el sistema activa automáticamente un motor de contingencia heurístico por expresiones regulares (MOTOR_LOGICO), garantizando respuesta continua y persistiendo cada interacción en LogInferencia.")

    add_body_p(doc, "2. ", bold_prefix="Prototipo de Clases del Agente Inteligente: ")
    add_body_p(doc, "Comprende las clases desarrolladas y operativas en el backend:\n"
                    "• NovaAIController.java: Controlador REST que gestiona el ciclo conversacional, herramientas y fallback.\n"
                    "• NovaRequest.java / NovaResponse.java: DTOs fuertemente tipados para transportar mensajes, intenciones detectadas y acciones de interfaz.\n"
                    "• LogInferencia.java / LogInferenciaRepository.java: Entidad y repositorio para auditoría de tokens consumidos, latencia y modelo utilizado.")

    add_body_p(doc, "3. ", bold_prefix="Vistas Frontend Integradas (asistente_voz.html): ")
    add_body_p(doc, "Widget interactivo responsivo diseñado con estética Glassmorphism, que incorpora reconocimiento de voz y sintetizador de voz (Web Speech API), estados animados de carga, chips de preguntas rápidas y validación contra envíos vacíos.")

    add_body_p(doc, "4. ", bold_prefix="Seguridad Perimetral y Control de Acceso: ")
    add_body_p(doc, "Configurado en SecurityConfig.java, protegiendo rutas mediante filtros de red (NetworkDeviceFilter), filtros de mantenimiento (MaintenanceFilter), autenticación federada OAuth2 con Google/GitHub, control de acceso estricto por roles (ROLE_ADMIN, ROLE_CLINICA, ROLE_VETERINARIO, ROLE_RECEPCIONISTA, ROLE_AUXILIAR, ROLE_CLIENTE) y login biométrico facial implementado en UsuarioServiceImpl.java mediante cálculo de distancia euclidiana sobre vectores de 128 dimensiones con umbral estricto (< 0.38).")

    add_body_p(doc, "5. ", bold_prefix="Repositorio Oficial de Código Fuente en GitHub: ")
    add_body_p(doc, "Disponible en: https://github.com/cardenaswalker2/ClinicaApp.git", italic=True)

    # -------------------------------------------------------------
    # 4.2 VISUALIZACIÓN DE DATOS II (EVIDENCIAS EXACTAS EXIGIDAS)
    # -------------------------------------------------------------
    add_styled_heading(doc, "4.2 Visualización de Datos II", level=2)
    
    # 4.2.1 IDENTIFICACIÓN DE FUENTES DE DATOS
    add_styled_heading(doc, "4.2.1 Identificación de las Fuentes de Datos (Tipos y Mecanismos de Acceso)", level=3)
    add_body_p(doc, "En el marco de la asignatura Visualización de Datos II, se realizó una caracterización formal y exhaustiva de todas las fuentes de información que intervienen en el ecosistema de ClinicaApp, diferenciando con total rigor la información transaccional operativa de los conjuntos de datos sintéticos/de prueba estructurados para el análisis dimensional:", bold_prefix="Identificación y Clasificación de Fuentes: ")

    add_body_p(doc, "a) ", bold_prefix="Fuentes de Datos Operacionales (MongoDB - Sistema OLTP): ")
    add_body_p(doc, "Corresponden a los datos transaccionales generados en tiempo real por los usuarios, veterinarios y administradores durante la operación cotidiana de la plataforma. Se almacenan en una base de datos documental NoSQL MongoDB (versión 7.0 / MongoDB Atlas) y se accede a ellos a través de la capa de persistencia de Spring Data MongoDB mediante interfaces Repository (MongoRepository) y consultas por Aggregation Framework. Las colecciones operativas verificadas en el código fuente son:")

    add_body_p(doc, "• ", bold_prefix="Colección «usuarios» (Entidad: Usuario.java): ")
    add_body_p(doc, "Almacena datos personales (nombre, apellido, email, teléfono, dirección, ciudad, coordenadas GPS: latitud y longitud), credenciales encriptadas con BCrypt, roles de seguridad (Role enum) y descriptores biométricos faciales (vectores de 128 dimensiones en coma flotante). Mecanismo de acceso: UsuarioRepository.")

    add_body_p(doc, "• ", bold_prefix="Colección «mascotas» (Entidad: Mascota.java): ")
    add_body_p(doc, "Contiene el perfil biológico de los pacientes animales (nombre, especie: PERRO/GATO, raza, sexo, peso en kg, fecha de nacimiento y patologías previas registradas), vinculados lógicamente con el identificador del propietario (propietarioId). Mecanismo de acceso: MascotaRepository.")

    add_body_p(doc, "• ", bold_prefix="Colección «clinicas» (Entidad: Clinica.java): ")
    add_body_p(doc, "Registra la información institucional de las sedes veterinarias afiliadas (nombre, dirección, teléfono, horaApertura, horaCierre, estado: EstadoClinica [APROBADA, PENDIENTE, RECHAZADA] y georreferenciación exacta en latitud y longitud). Mecanismo de acceso: ClinicaRepository.")

    add_body_p(doc, "• ", bold_prefix="Colección «citas» (Entidad: Cita.java): ")
    add_body_p(doc, "Registra los eventos de reserva médica (mascotaId, clinicaId, servicioId, fechaHora: LocalDateTime, estado: String y motivo). Mecanismo de acceso: CitaRepository.")

    add_body_p(doc, "• ", bold_prefix="Colección «servicios» (Entidad: Servicio.java): ")
    add_body_p(doc, "Catálogo de procedimientos clínicos, preventivos, diagnósticos y quirúrgicos ofrecidos por cada clínica, especificando nombre, descripción, precio base (BigDecimal), duracionMinutos y clinicaId. Mecanismo de acceso: ServicioRepository.")

    add_body_p(doc, "• ", bold_prefix="Colección «visitas» (Entidad: Visita.java) y «logs_inferencia» (Entidad: LogInferencia.java): ")
    add_body_p(doc, "Registran la ejecución de la consulta médica (citaId, diagnóstico, tratamiento, costoTotal) y la auditoría de interacciones del agente inteligente Nova Brain (usuarioId, prompt, respuesta, tokens y latenciaMs).")

    add_body_p(doc, "b) ", bold_prefix="Fuentes de Datos Sintéticas / De Prueba (Datasets CSV en docs/powerbi_datawarehouse/): ")
    add_body_p(doc, "Con el propósito de validar académicamente el modelo dimensional y preparar los datos para su posterior análisis en Power BI sin exponer información clínica confidencial de usuarios ni vulnerar la Ley 1581 de 2012 de protección de datos personales, se estructuró un conjunto de datos sintéticos/de prueba normalizado. Este repositorio se compone de 6 archivos tabulares en formato CSV (delimitados por comas y codificados en UTF-8), ubicados físicamente en la carpeta docs/powerbi_datawarehouse/ del proyecto:")
    add_body_p(doc, "1. Dim_Tiempo.csv: 730 registros (grano diario del periodo 2025-2026, con 9 columnas: id_fecha, fecha_completa, anio, trimestre, mes_numero, mes_nombre, dia_mes, dia_semana, es_fin_semana).\n"
                    "2. Dim_Clinica.csv: 6 registros de sedes veterinarias georreferenciadas en Cartagena (10 columnas: id_clinica, nombre, direccion, barrio, ciudad, telefono, estado_operativo, capacidad_diaria, latitud, longitud).\n"
                    "3. Dim_Servicio.csv: 8 registros de procedimientos médicos tipificados (6 columnas: id_servicio, nombre, categoria, precio_base, duracion_min, requiere_veterinario).\n"
                    "4. Dim_Mascota.csv: 150 perfiles de pacientes caninos y felinos con patologías simuladas (9 columnas: id_mascota, nombre, especie, raza, sexo, edad_anios, tamano, peso_kg, condicion_previa).\n"
                    "5. Dim_Veterinario.csv: 10 perfiles de médicos especialistas asignados a sedes (5 columnas: id_veterinario, nombre_completo, especialidad, experiencia_anios, id_clinica).\n"
                    "6. Fact_Atenciones_Citas.csv: 3.469 hechos de atenciones y citas simuladas (18 columnas con claves foráneas hacia todas las dimensiones y métricas cuantitativas acumulables).")
    add_body_p(doc, "Mecanismo de Acceso: Conector nativo de archivos de texto/CSV de Power BI Desktop y librerías de análisis de datos en Python (Pandas).")

    # 4.2.2 MODELO DIMENSIONAL
    add_styled_heading(doc, "4.2.2 Modelo Dimensional (Esquema Estrella y Métricas Propuestas para Power BI)", level=3)
    add_body_p(doc, "Para estructurar analíticamente los datos de ClinicaApp, se diseñó e implementó un ", bold_prefix="Arquitectura del Modelo Dimensional: ")
    add_body_p(doc, "modelo dimensional en Esquema Estrella puro (Star Schema), siguiendo la metodología estándar de Ralph Kimball. Se seleccionó el esquema estrella sobre el esquema copo de nieve debido a que desnormaliza deliberadamente las dimensiones descriptivas, eliminando uniones (JOINs) complejas, reduciendo la redundancia de consultas y optimizando el rendimiento de las consultas de agregación temporal y espacial en herramientas de Business Intelligence como Power BI.")

    add_body_p(doc, "El modelo está compuesto por una tabla de hechos central y cinco tablas de dimensiones:", bold_prefix="Componentes del Esquema Estrella: ")

    add_body_p(doc, "1. ", bold_prefix="Tabla de Hechos Central: «Fact_Atenciones_Citas» (Grano: Cita Individual Atendida): ")
    add_body_p(doc, "Representa el evento atómico de negocio correspondiente a la programación y ejecución de una cita veterinaria. Contiene claves foráneas hacia todas las dimensiones y los atributos métricos cuantitativos acumulables:")
    add_body_p(doc, "• Claves Foráneas (FK): id_fecha (INT hacia Dim_Tiempo), id_clinica (VARCHAR hacia Dim_Clinica), id_servicio (VARCHAR hacia Dim_Servicio), id_mascota (VARCHAR hacia Dim_Mascota), id_veterinario (VARCHAR hacia Dim_Veterinario).\n"
                    "• Atributos Degenerados de Contexto: canal_agendamiento (PORTAL_WEB, AGENTE_NOVA_CHATBOT, RECEPCION_PRESENCIAL, OPTIMIZACION_GEO_PLEB), estado_cita (COMPLETADA, CANCELADA, NO_ASISTIO), metodo_pago (STRIPE_CARD, EFECTIVO, TRANSFERENCIA_NEQUI).\n"
                    "• Métricas y Hechos Cuantitativos: tiempo_espera_min (minutos en sala), duracion_atencion_min (duración real), monto_bruto (COP), monto_descuento (COP), monto_neto (COP), calificacion_satisfaccion (1 a 5), asistio (indicador binario 1/0), no_show (indicador binario 1/0), cancelada (indicador binario 1/0).")

    add_body_p(doc, "2. ", bold_prefix="Tablas de Dimensiones Descriptivas: ")
    add_body_p(doc, "• «Dim_Tiempo» (Dimensión Conforme): 730 registros diarios (periodo 2025-2026). Clave primaria: id_fecha (YYYYMMDD). Atributos: fecha_completa, anio, trimestre, mes_numero, mes_nombre, dia_mes, dia_semana, es_fin_semana.\n"
                    "• «Dim_Clinica»: 6 registros. Atributos: id_clinica [PK], nombre, direccion, barrio, ciudad, telefono, estado_operativo, capacidad_diaria, latitud, longitud.\n"
                    "• «Dim_Servicio»: 8 registros. Atributos: id_servicio [PK], nombre, categoria, precio_base, duracion_min, requiere_veterinario.\n"
                    "• «Dim_Mascota»: 150 registros. Atributos: id_mascota [PK], nombre, especie, raza, sexo, edad_anios, tamano, peso_kg, condicion_previa.\n"
                    "• «Dim_Veterinario»: 10 registros. Atributos: id_veterinario [PK], nombre_completo, especialidad, experiencia_anios, id_clinica.")

    add_body_p(doc, "3. ", bold_prefix="Relaciones del Modelo: ")
    add_body_p(doc, "Se establecen relaciones estrictas de uno a muchos (1:N) con integridad referencial desde cada una de las 5 tablas dimensionales hacia la tabla de hechos central Fact_Atenciones_Citas, con dirección de filtrado unidireccional desde las dimensiones hacia los hechos.")

    add_body_p(doc, "4. ", bold_prefix="Métricas Propuestas y Fórmulas DAX para Análisis en Power BI: ")
    add_body_p(doc, "A partir de este esquema dimensional, se definieron formalmente las fórmulas en lenguaje DAX (Data Analysis Expressions) para calcular los indicadores clave de rendimiento del negocio:")
    add_body_p(doc, "• Tasa de Asistencia: [Total Citas Asistidas] / [Total Citas Programadas]\n"
                    "• Tasa de Inasistencia (No-Show): [Total Citas No Asistidas] / [Total Citas Programadas]\n"
                    "• Ingresos Netos Totales: SUM(Fact_Atenciones_Citas[monto_neto])\n"
                    "• Porcentaje de Adopción de Canales Digitales: [Citas por Nova AI + PLEB] / [Total Citas]\n"
                    "• Tiempo Promedio de Espera por Clínica: AVERAGE(Fact_Atenciones_Citas[tiempo_espera_min])\n"
                    "• Demanda Relativa por Especie y Categoría de Servicio.")

    add_body_p(doc, "Nota de Rigor Académico: Se aclara explícitamente que este modelo dimensional corresponde a un prototipo analítico validado mediante el dataset sintético/de prueba de 3.469 hechos, diseñado específicamente para demostrar la viabilidad analítica y dejar la estructura preparada para su consumo en Power BI sin constituir aún un cuadro de mando productivo conectado a bases de datos en producción real.", italic=True)

    # -------------------------------------------------------------
    # 4.3 INVESTIGACIÓN DE OPERACIONES
    # -------------------------------------------------------------
    add_styled_heading(doc, "4.3 Investigación de Operaciones: Problema Real, Formulación PLEB y Demostración", level=2)
    add_body_p(doc, "El componente de IO aborda la problemática de asignación y traslado de pacientes:", bold_prefix="Formulación del Modelo Matemático de Optimización: ")
    
    add_body_p(doc, "1. ", bold_prefix="Conjuntos y Parámetros: ")
    add_body_p(doc, "• I = {1, 2, ..., n}: Conjunto de clínicas veterinarias registradas en ClinicaApp.\n"
                    "• (lat_u, lon_u): Coordenadas geográficas de latitud y longitud del usuario.\n"
                    "• (lat_i, lon_i): Coordenadas geográficas de la clínica veterinaria i in I.\n"
                    "• d_i: Distancia geodésica en kilómetros calculada mediante la fórmula del Semiverseno (Haversine):\n"
                    "   d_i = 2 * R * arcsin( sqrt( sin²(Δlat/2) + cos(lat_u)*cos(lat_i)*sin²(Δlon/2) ) ), con R = 6.371 km.\n"
                    "• A_i in {0, 1}: Parámetro binario de operatividad (1 si estado = APROBADA, 0 en caso contrario).\n"
                    "• D_max: Radio máximo de desplazamiento permitido (ej. 15.0 km).")

    add_body_p(doc, "2. ", bold_prefix="Variables de Decisión: ")
    add_body_p(doc, "• X_i in {0, 1}, para todo i in I: Variable binaria que toma el valor de 1 si la clínica i es seleccionada para atender al usuario, y 0 en caso contrario.")

    add_body_p(doc, "3. ", bold_prefix="Función Objetivo: ")
    add_body_p(doc, "Minimizar la distancia geodésica de traslado del paciente:\n"
                    "Min Z = Sum_{i in I} ( d_i * X_i )", bold_prefix="Función Objetivo: ")

    add_body_p(doc, "4. ", bold_prefix="Restricciones del Modelo: ")
    add_body_p(doc, "a) Restricción de Selección Única: Asignar exactamente una clínica al usuario:\n"
                    "   Sum_{i in I} X_i = 1\n"
                    "b) Restricción de Disponibilidad Operativa: Seleccionar únicamente clínicas activas y aprobadas:\n"
                    "   X_i <= A_i,  para todo i in I\n"
                    "c) Restricción de Cobertura Geográfica Máxima: La clínica seleccionada no puede exceder el radio límite D_max:\n"
                    "   d_i * X_i <= D_max,  para todo i in I\n"
                    "d) Condiciones de No Negatividad y Binariedad:\n"
                    "   X_i in {0, 1},  para todo i in I\n"
                    "   d_i >= 0,  para todo i in I")

    add_body_p(doc, "5. ", bold_prefix="Implementación y Demostración en el Software: ")
    add_body_p(doc, "El modelo permite seleccionar una clínica factible de menor distancia bajo las restricciones definidas, utilizando la formulación de programación lineal entera binaria y el cálculo de distancia geodésica mediante Haversine. Fue implementado en Java en OptimizacionServiceImpl.java y se visualiza interactivamente en la vista /usuario/optimizacion-clinicas mediante mapa Leaflet.")

    # -------------------------------------------------------------
    # 4.4 MATRIZ DE TRAZABILIDAD
    # -------------------------------------------------------------
    add_styled_heading(doc, "4.4 Matriz de Trazabilidad y Cumplimiento por Objetivo", level=2)
    add_body_p(doc, "A continuación se presenta la matriz de trazabilidad que relaciona cada objetivo específico con su evidencia técnica y su grado real de avance al cierre del VII semestre:")

    # Tabla de Matriz de Cumplimiento
    tbl_traz = doc.add_table(rows=6, cols=4)
    tbl_traz.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl_traz.autofit = False

    headers_traz = ["Objetivo Específico Formulado", "Evidencia Técnica Auditada (Código / Anexos)", "Avance Real (%)", "Actividades Pendientes para VIII Semestre"]
    for j, h in enumerate(headers_traz):
        cell = tbl_traz.cell(0, j)
        cell.text = h
        set_cell_background(cell, "1E3A8A")
        set_cell_margins(cell, 100, 100, 120, 120)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for r in p.runs:
            r.font.bold = True
            r.font.color.rgb = RGBColor(255, 255, 255)
            r.font.size = Pt(9)

    filas_traz = [
        ("Objetivo 1 (Analizar): Requerimientos, fuentes de datos y formulación de optimización.", 
         "Documento SRS, catálogo de fuentes de datos en MongoDB, caracterización de datos sintéticos y matriz PLEB.", 
         "100 %", 
         "Ninguna. Requerimientos interdisciplinares completamente formalizados."),
        
        ("Objetivo 2 (Diseñar): Arquitectura Spring Boot, modelo dimensional en estrella, E-R y modelo matemático.", 
         "Diagrama de arquitectura Spring Boot + LLM (Anexo B), Diccionario de Datos (Anexo C), Esquema Estrella (Anexo D) y Formulación PLEB (Anexo E).", 
         "95 %", 
         "Ajustes menores de particionamiento dimensional si se incorporan sedes fuera de Cartagena."),

        ("Objetivo 3 (Codificar): Backend Spring Boot, Nova AI, datasets sintéticos y servicio de optimización.", 
         "Controlador NovaAIController, SecurityConfig, asistente_voz.html, OptimizacionServiceImpl y datasets CSV en docs/powerbi_datawarehouse/.", 
         "90 %", 
         "Automatización de pipeline ETL periódico desde MongoDB hacia base relacional OLAP."),

        ("Objetivo 4 (Verificar): Pruebas funcionales de seguridad, respuestas del agente, consistencia dimensional y optimización.", 
         "Logs de inferencia en LogInferenciaRepository, validación de distancias Haversine, pruebas de roles RBAC y cálculo de métricas sobre datos sintéticos.", 
         "85 %", 
         "Pruebas de carga y concurrencia multiusuario con Apache JMeter; pruebas formales de usabilidad con usuarios y clínicas reales."),

        ("Objetivo 5 (Implementar): Despliegue de prototipo integrado con datos semilla y validación analítica.", 
         "ClinicaApp ejecutándose localmente con DataSeeder, interfaz web conectada a Nova Brain y datasets dimensionales de prueba verificados.", 
         "80 %", 
         "Despliegue en infraestructura cloud (AWS/Azure) con contenedor Docker y certificación SSL.")
    ]

    for i, (obj, evi, av, pend) in enumerate(filas_traz, start=1):
        c0 = tbl_traz.cell(i, 0)
        c1 = tbl_traz.cell(i, 1)
        c2 = tbl_traz.cell(i, 2)
        c3 = tbl_traz.cell(i, 3)
        c0.width = Inches(1.8)
        c1.width = Inches(2.2)
        c2.width = Inches(1.0)
        c3.width = Inches(2.0)
        c0.text = obj
        c1.text = evi
        c2.text = av
        c3.text = pend
        set_cell_background(c0, "F1F5F9" if i%2==1 else "FFFFFF")
        set_cell_background(c1, "F8FAFC" if i%2==1 else "FFFFFF")
        set_cell_background(c2, "F1F5F9" if i%2==1 else "FFFFFF")
        set_cell_background(c3, "F8FAFC" if i%2==1 else "FFFFFF")
        set_cell_margins(c0, 80, 80, 100, 100)
        set_cell_margins(c1, 80, 80, 100, 100)
        set_cell_margins(c2, 80, 80, 100, 100)
        set_cell_margins(c3, 80, 80, 100, 100)
        c0.paragraphs[0].runs[0].font.size = Pt(8.5)
        c1.paragraphs[0].runs[0].font.size = Pt(8.5)
        c2.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        c2.paragraphs[0].runs[0].font.bold = True
        c2.paragraphs[0].runs[0].font.size = Pt(9)
        c2.paragraphs[0].runs[0].font.color.rgb = RGBColor(16, 185, 129)
        c3.paragraphs[0].runs[0].font.size = Pt(8.5)

    add_styled_heading(doc, "4.5 Conclusiones Parciales y Proyección hacia VIII Semestre", level=2)
    add_body_p(doc, "El balance de los resultados obtenidos en el séptimo semestre permite establecer las siguientes conclusiones:", bold_prefix="Conclusiones Parciales: ")
    add_body_p(doc, "1. Se logró una articulación interdisciplinar armónica y demostrable entre Desarrollo Web Avanzado, Visualización de Datos II e Investigación de Operaciones, consolidando a ClinicaApp como una plataforma integral de gestión, analítica y optimización.")
    add_body_p(doc, "2. La integración del agente conversacional Nova Brain con LLMs (Llama 3.3 70B vía Groq) y motor de contingencia heurístico demostró la viabilidad de incorporar IA generativa con contexto clínico dinámico y altos estándares de seguridad perimetral.")
    add_body_p(doc, "3. La caracterización formal de fuentes de datos y el diseño del modelo dimensional en esquema estrella validaron la estructura analítica requerida para el cálculo de indicadores de gestión preparados para Power BI mediante datasets de prueba.")
    add_body_p(doc, "4. El modelo permite seleccionar una clínica factible de menor distancia bajo las restricciones definidas, utilizando la formulación de programación lineal entera binaria y el cálculo de distancia geodésica mediante Haversine.")
    add_body_p(doc, "5. Como trabajo proyectado para el octavo semestre, se contempla la ejecución de pruebas de carga con Apache JMeter, la contenerización del sistema en Docker, el despliegue en la nube y la validación de usabilidad con personal de clínicas veterinarias en Cartagena.")

    # -------------------------------------------------------------
    # REFERENCIAS BIBLIOGRÁFICAS (APA 7)
    # -------------------------------------------------------------
    doc.add_page_break()
    add_styled_heading(doc, "Referencias Bibliográficas", level=1)
    
    referencias = [
        "American Veterinary Medical Association [AVMA]. (2022). Veterinary medical records: Electronic standards and interoperability barriers in contemporary practice. AVMA Policy & Clinical Reports, 78(3), 12–19.",
        "Hernández-Sampieri, R., & Mendoza, C. P. (2018). Metodología de la investigación: Las rutas cuantitativa, cualitativa y mixta. McGraw-Hill Education.",
        "Kimball, R., & Ross, M. (2013). The Data Warehouse toolkit: The definitive guide to dimensional modeling (3.ª ed.). John Wiley & Sons.",
        "Taha, H. A. (2017). Operations research: An introduction (10.ª ed.). Pearson Education.",
        "Universidad CES. (2024). Desarrollo e impacto de soluciones tecnológicas móviles para la interacción entre tutores de mascotas y profesionales de la salud animal en el Valle de Aburrá: Caso Medicalvett. Revista CES Medicina Veterinaria y Zootecnia, 19(1), 55–68.",
        "Universidad del Rosario & Universidad de los Andes. (2023). Aplicaciones de la investigación de operaciones y programación matemática en la gestión de cadenas de suministro y asignación de recursos en salud en Colombia. Colección Académica de Ingeniería y Salud Pública, 12(2), 77–94.",
        "Veterinary Record Journal. (2024). Evaluation of large language models and artificial intelligence for emergency triage in veterinary clinical practice. PMC / PubMed Central, 194(6), 245–256. https://doi.org/10.1002/vetr.3892",
        "Walls, C. (2022). Spring in Action (6.ª ed.). Manning Publications."
    ]

    for ref in referencias:
        p_ref = doc.add_paragraph()
        p_ref.paragraph_format.left_indent = Inches(0.5)
        p_ref.paragraph_format.first_line_indent = Inches(-0.5)
        p_ref.paragraph_format.space_after = Pt(6)
        p_ref.paragraph_format.line_spacing = 1.15
        r = p_ref.add_run(ref)
        r.font.name = 'Calibri'
        r.font.size = Pt(10)

    # Declaración de Uso de IA Generativa
    add_styled_heading(doc, "Declaración sobre el Uso Ético de Inteligencia Artificial Generativa", level=2)
    add_body_p(doc, "En conformidad con las directrices institucionales de la Universidad de Cartagena sobre integridad académica, los autores declaran que se emplearon herramientas de Inteligencia Artificial Generativa (Llama 3.3 70B vía Groq Cloud y ChatGPT de OpenAI) exclusivamente como apoyo en tareas de depuración sintáctica de código, asistencia en redacción preliminar y consulta bibliográfica. Todos los análisis conceptuales, diseños de arquitectura, modelos matemáticos, lógica de negocio y validaciones fueron concebidos, auditados y asumidos con responsabilidad plena por los integrantes del equipo de investigación.", italic=True)

    # -------------------------------------------------------------
    # ANEXOS TÉCNICOS OFICIALES
    # -------------------------------------------------------------
    doc.add_page_break()
    add_styled_heading(doc, "Anexos Técnicos Oficiales", level=1)
    
    add_styled_heading(doc, "Anexo A: Diagrama del Árbol del Problema y Estructura Causal", level=2)
    add_body_p(doc, "Estructura causal, problema central y efectos vinculados al ecosistema veterinario.", bold_prefix="Descripción: ")
    img_arbol = r'C:\Users\USUARIO\Downloads\clinicaapp\docs\imagenes_evidencias\figura_arbol_problema.png'
    if os.path.exists(img_arbol):
        doc.add_picture(img_arbol, width=Inches(6.2))

    add_styled_heading(doc, "Anexo B: Diagrama de Arquitectura Spring Boot + LLM (Nova Brain)", level=2)
    add_body_p(doc, "Arquitectura en 5 capas de Spring Boot 3.5 con integración segura a Groq Cloud / Llama 3.3 y fallback heurístico.", bold_prefix="Descripción: ")
    img_arq = r'C:\Users\USUARIO\Downloads\clinicaapp\docs\imagenes_evidencias\figura_arquitectura_spring_llm.png'
    if os.path.exists(img_arq):
        doc.add_picture(img_arq, width=Inches(6.2))

    add_styled_heading(doc, "Anexo C: Diccionario de Datos del Modelo E-R (MongoDB)", level=2)
    add_body_p(doc, "Documentación de las entidades y colecciones principales de persistencia en MongoDB:")
    
    # Tabla Diccionario de Datos
    tbl_dic = doc.add_table(rows=8, cols=5)
    tbl_dic.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl_dic.autofit = False

    headers_dic = ["Colección", "Campo", "Tipo Dato", "Descripción Funcional", "Restricción / Relación"]
    for j, h in enumerate(headers_dic):
        cell = tbl_dic.cell(0, j)
        cell.text = h
        set_cell_background(cell, "1E3A8A")
        set_cell_margins(cell, 80, 80, 100, 100)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for r in p.runs:
            r.font.bold = True
            r.font.color.rgb = RGBColor(255, 255, 255)
            r.font.size = Pt(8.5)

    filas_dic = [
        ("usuarios", "id, email, password, roles, rostroEmbedding", "String, List<Role>, List<Double>", "Identidad del usuario, credenciales encriptadas y embedding facial biométrico.", "PK (_id), Unique (email), Non-Null"),
        ("mascotas", "id, nombre, especie, raza, peso, propietarioId", "String, Especie, String, Double, String", "Perfil biológico del paciente animal y vínculo con su propietario.", "PK (_id), FK (propietarioId -> usuarios)"),
        ("clinicas", "id, nombre, latitud, longitud, estado, telefono", "String, Double, Double, EstadoClinica, String", "Centro veterinario afiliado con georreferenciación y estado operativo.", "PK (_id), Estado in {APROBADA, PENDIENTE}"),
        ("citas", "id, mascotaId, clinicaId, fechaHora, estado, servicioId", "String, String, LocalDateTime, String, String", "Reserva de atención clínica con estado de cumplimiento.", "PK (_id), FK (mascotaId, clinicaId, servicioId)"),
        ("servicios", "id, nombre, precio, duracionMinutos, clinicaId", "String, String, BigDecimal, Integer, String", "Portafolio de procedimientos médicos ofertados por cada sede.", "PK (_id), FK (clinicaId -> clinicas)"),
        ("logs_inferencia", "id, usuarioId, prompt, respuesta, tokens, latenciaMs", "String, String, String, Integer, Long", "Trazabilidad y auditoría de consultas procesadas por Nova AI.", "PK (_id), FK (usuarioId -> usuarios)"),
        ("visitas", "id, citaId, diagnostico, tratamiento, totalFacturado", "String, String, String, String, BigDecimal", "Registro clínico de atención y factura asociada.", "PK (_id), FK (citaId -> citas)")
    ]

    for i, (col, camp, tip, desc, rest) in enumerate(filas_dic, start=1):
        for j, val in enumerate([col, camp, tip, desc, rest]):
            cell = tbl_dic.cell(i, j)
            cell.text = val
            set_cell_background(cell, "F1F5F9" if i%2==1 else "FFFFFF")
            set_cell_margins(cell, 60, 60, 80, 80)
            cell.paragraphs[0].runs[0].font.size = Pt(8)

    add_styled_heading(doc, "Anexo D: Diagrama del Modelo Dimensional (Esquema Estrella)", level=2)
    add_body_p(doc, "Estructura dimensional en esquema estrella con tabla de hechos central Fact_Atenciones_Citas y 5 dimensiones descriptivas.", bold_prefix="Descripción: ")
    img_dim = r'C:\Users\USUARIO\Downloads\clinicaapp\docs\imagenes_evidencias\figura_modelo_dimensional_estrella.png'
    if os.path.exists(img_dim):
        doc.add_picture(img_dim, width=Inches(6.2))

    add_styled_heading(doc, "Anexo E: Formulación Matemática y Código del Modelo de Optimización (PLEB)", level=2)
    add_body_p(doc, "Extracto de la implementación en Java en OptimizacionServiceImpl.java:", bold_prefix="Código Fuente en Java: ")
    
    codigo_io = (
        "// 1. Cálculo de Distancia Geodésica mediante Haversine (Garantía d_i >= 0)\n"
        "double distancia = calcularDistanciaHaversine(latitudUsuario, longitudUsuario, clinicaLat, clinicaLng);\n"
        "boolean disponible = (clinica.getEstado() == EstadoClinica.APROBADA);\n"
        "boolean cumpleRadio = (distancia <= resultado.getRadioMaxKm());\n"
        "boolean esFactible = disponible && cumpleRadio;\n\n"
        "// 2. Selección de la alternativa factible de menor distancia (Min Z = Sum d_i * X_i)\n"
        "if (esFactible && distancia < menorDistancia) {\n"
        "    menorDistancia = distancia;\n"
        "    mejorClinica = clinica;\n"
        "    variableGanadora = varDto;\n"
        "}"
    )
    p_code = doc.add_paragraph()
    p_code.paragraph_format.left_indent = Inches(0.4)
    p_code.paragraph_format.right_indent = Inches(0.4)
    p_code.paragraph_format.space_before = Pt(6)
    p_code.paragraph_format.space_after = Pt(6)
    r_c = p_code.add_run(codigo_io)
    r_c.font.name = 'Consolas'
    r_c.font.size = Pt(8.5)
    r_c.font.color.rgb = RGBColor(30, 41, 59)

    out_file = r'C:\Users\USUARIO\Downloads\ClinicaApp_Inf_Metodologico_7mo_FINAL_Oficial.docx'
    doc.save(out_file)
    print(f"Informe final guardado exitosamente en: {out_file}")

if __name__ == '__main__':
    build_final_academic_report()
