[English](TESTING-UPGRADE.md) | [Español](TESTING-UPGRADE.es.md)

# Pruebas de los Scripts de Actualización ZaneyOS 2.3 → 2.4

## 🧪 Configuración del Entorno de Pruebas

Esta rama (históricamente `ddubs-dev`) contiene los scripts de actualización para pruebas seguras antes de fusionar a main.

### Prerrequisitos para Probar:
- Un sistema ZaneyOS 2.3 (rama stable-2.3)
- Acceso a los archivos de la rama main
- Respaldo de tu sistema (el script crea uno, pero también se recomienda respaldo manual)

### Obtén el script de forma segura (NO hagas `git pull` todavía)
Para evitar sobrescribir tu configuración local antes de tener un respaldo, descarga solo el script sin alterar tu working tree:

Opción A — Usando tu remoto git existente:
```bash
git -C ~/zaneyos fetch origin
git -C ~/zaneyos show origin/main:upgrade-2.3-to-2.4.sh > ~/upgrade-2.3-to-2.4.sh
chmod +x ~/upgrade-2.3-to-2.4.sh
```

Opción B — Usando curl:
```bash
curl -fsSL https://gitlab.com/zaney/zaneyos/-/raw/main/upgrade-2.3-to-2.4.sh -o ~/upgrade-2.3-to-2.4.sh
chmod +x ~/upgrade-2.3-to-2.4.sh
```

## 📋 Plan de Pruebas

### Fase 1: Validación del Script
1. **Chequeo de Sintaxis**: Verifica que los scripts no tengan errores de sintaxis
2. **Dry Run**: Prueba la detección de versión y creación de respaldo
3. **Permisos**: Asegura que los scripts sean ejecutables y con permisos correctos

### Fase 2: Pruebas de Respaldo  
1. **Creación de Respaldo**: Verifica que se cree un respaldo completo
2. **Integridad del Respaldo**: Confirma que el respaldo contenga los archivos necesarios
3. **Prueba de Reversión**: Prueba el revert sin realizar la actualización

### Fase 3: Pruebas de Actualización
1. **Actualización Completa**: Realiza la actualización 2.3 → 2.4
2. **Migración de Configuración**: Verifica que se preserven todos los ajustes
3. **Manejo de Terminales**: Confirma que las terminales queden habilitadas correctamente
4. **Transición a SDDM**: Prueba la seguridad del cambio de display manager

### Fase 4: Validación Post-Actualización
1. **Arranque del Sistema**: Verifica que el sistema arranque correctamente con SDDM
2. **Funcionalidad de Aplicaciones**: Prueba que todas las aplicaciones funcionen
3. **Persistencia de Configuración**: Confirma que se preservaron los ajustes personalizados

## 🔧 Comandos de Prueba

### Para obtener la rama de pruebas (si aplica históricamente):
```bash
cd ~/zaneyos
git fetch origin
git checkout ddubs-dev
git pull origin ddubs-dev
```

### Probar Sintaxis de Scripts:
```bash
bash -n upgrade-2.3-to-2.4.sh
bash -n revert-to-2.3.sh
```

### Probar Detección de Versión (Seguro):
```bash
# Esto solo verificará la versión y creará un respaldo, luego saldrá
./upgrade-2.3-to-2.4.sh
# Responde 'N' cuando pregunte si desea continuar
```

### Probar la Reversión:
```bash
# Tras crear un respaldo, prueba la reversión
./upgrade-2.3-to-2.4.sh --revert
# O usa el wrapper
./revert-to-2.3.sh
```

## 📊 Plantilla de Resultados de Prueba

### Configuración del Sistema:
- **Versión Actual**: 2.3 (rama: stable-2.3)
- **Terminal Usada**: [kitty/alacritty/wezterm/ghostty]
- **Ajustes Personalizados**: [lista de personalizaciones]
- **Hardware**: [descripción breve]

### Resultados:

#### ✅ Pre-Flight:
- [ ] Validación de sintaxis ok
- [ ] Detección de versión correcta
- [ ] Respaldo creado con éxito
- [ ] Herramientas requeridas detectadas (git, nh, etc.)

#### ✅ Respaldo y Reversión:
- [ ] Respaldo completo creado
- [ ] Ubicación del respaldo mostrada claramente
- [ ] Script de revert funciona
- [ ] Sistema restaurado a 2.3 tras revert
- [ ] Ajustes originales preservados

#### ✅ Proceso de Actualización:
- [ ] Migración de configuración completa
- [ ] Manejo de terminal correcto
- [ ] Build con opción 'boot' exitoso
- [ ] Sin errores durante la actualización

#### ✅ Post-Actualización:
- [ ] Sistema reinicia correctamente
- [ ] SDDM se muestra correctamente (sin pantalla en negro)
- [ ] DE carga correctamente
- [ ] Terminal preferida funciona
- [ ] Aplicaciones funcionan
- [ ] Ajustes (tema, fondo, etc.) preservados

### Problemas Encontrados:
[Describe cualquier problema]

### Recomendaciones:
[Sugerencias de mejora]

## 🚨 Notas de Seguridad

1. **Probar en VM** recomendado
2. **Respaldo externo** adicional
3. **Plan de recuperación** (USB live de NixOS)
4. **Tiempo**: reserva 1–2 horas
5. **Red** estable para descargas

## 📝 Reporte de Resultados

Incluye:
1. Especificaciones del sistema
2. Configuración inicial (rama 2.3 y personalizaciones)
3. Resultados completos usando la plantilla
4. Mensajes de error o logs
5. Capturas de pantalla

## 🔄 Iteración

Tras probar:
1. Reporta resultados e incidencias
2. Se aplican mejoras
3. Re‑prueba
4. Cuando sea estable, fusionar a main

## 📞 Soporte durante pruebas

Si encuentras problemas:
1. Revisa el archivo de log (ruta mostrada por el script)
2. Prueba la reversión a 2.3
3. Reporta el problema incluyendo el log
4. Tu respaldo siempre está disponible para recuperación manual

¡Recuerda! Es software en pruebas: ten siempre un plan de recuperación.
