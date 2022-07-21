import DiscordJS, { IntentsBitField } from 'discord.js'
import fs from 'fs'
// eslint-disable-next-line no-new-func
const importDynamic = new Function('modulePath', 'return import(modulePath)');

const fetch = async (...args:any[]) => {
  const module = await importDynamic('node-fetch');
  return module.default(...args);
};
import dotenv from 'dotenv'
import { exec } from 'child_process'
dotenv.config()

const client = new DiscordJS.Client({
    intents: [
        IntentsBitField.Flags.Guilds,
        IntentsBitField.Flags.GuildMessages,
        IntentsBitField.Flags.MessageContent,
    ],
})

client.on('ready', () => {
    console.log('The bot is ready')

    const guild = client.guilds.cache.get('999483086788100096')
    let commands

    if (guild) {
        commands = guild.commands
    } else {
        commands = client.application?.commands
    }

    commands?.create({
        name: 'obfuscate',
        description: 'Obfuscates your lua script.',
        options: [
            {
                name: 'code',
                description: 'Lua file to obfuscate',
                required: true,
                type: DiscordJS.ApplicationCommandOptionType.Attachment
            }
        ]
    })
})

client.on('interactionCreate', async (interaction) => {
    if (!interaction.isChatInputCommand()) return

    const { commandName, options } = interaction

    if (commandName == 'obfuscate') {
        const attachment = options.getAttachment('code')
        const file = attachment?.url
        if (!file) return console.log('No attached file found')

        try {
            const response = await fetch(file)
            if (!response.ok) {
                interaction.reply(
                    `There was an error with fetching the file: ${response.statusText}`,
                )
                return
            }

            const text = await response.text()
            fs.writeFile("temp.lua", text, (err) => {
                if (err) return console.log(err)
                // file written successfully
                exec("compileTemp.bat", (error, stdout, stderr) => {
                    if (error) return interaction.reply("There was an error with obfuscating the script")
                    interaction.reply({
                        content: "Obfuscated Script",
                        ephemeral: true,
                        files: [
                            "temp.obfuscated.lua"
                        ]
                    })
                })
            })
        } catch (error) {
            console.log(error)
        }
    }
})

client.login(process.env.TOKEN)