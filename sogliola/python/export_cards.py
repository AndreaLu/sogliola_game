import bpy

# Sostituisci 'NomeOggetto' con il nome del tuo oggetto
names = ("AqPlPos","AqOpPos","DckPlPos","DckOpPos","OceanPos","HndOpPos","HndPlPos")

output_file_path = bpy.path.abspath("D:/cloud/projects/sogliole/game/sogliola/datafiles/cards.json")

# Controlla se l'oggetto esiste nella scena
with open(output_file_path,"w") as fout:
    for nome_oggetto in names:
        if nome_oggetto in bpy.data.objects:
            oggetto = bpy.data.objects[nome_oggetto]
            
            # Ottieni la posizione dell'oggetto
            posizione = oggetto.location
            rotazione = oggetto.rotation_euler
            
            fout.write(str(posizione.x) + "\n")
            fout.write(str(posizione.y) + "\n")
            fout.write(str(posizione.z) + "\n")
            
            fout.write(str(rotazione.x) + "\n")
            fout.write(str(rotazione.y) + "\n")
            fout.write(str(rotazione.z) + "\n")
        else:
            print(f"L'oggetto con il nome '{nome_oggetto}' non esiste nella scena.")
