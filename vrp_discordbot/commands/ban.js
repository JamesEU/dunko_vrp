exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !params[1] || !/^\d{1,10}$/.test(params[0]) || !/^\d{1,6}$/.test(params[1]) || !parseInt(params[1])) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'ban [permid] [time (hours)] [reason]')
    }
    const reason = params.slice(2).join(' ');
    let newval = fivemexports.vrp.vrpbot('banConsole', [parseInt(params[0]), parseInt(params[1]), `${reason}\nBanning Discord Admin: ${message.author.username} (${message.author.id})\n Note this ban was carried out in Discord by the above staff member through the console banning function.`])
    let embed = {
        "title": "Banned User",
        "description": `\nSuccess! Banned User with PermID: ${params[0]} With ${params[1]} hours and the reason: ${reason}`,
        "color": 5301186,
        "footer": {
            "text": "vRP • Made by JamesUK#6793"
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "ban",
    perm: 2
}