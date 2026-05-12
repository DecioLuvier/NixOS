import Gio from "gi://Gio";

export function exec(argv) {
    const proc = Gio.Subprocess.new(argv, Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE)
    const [, stdout, stderr] = proc.communicate_utf8(null, null)

    if (proc.get_successful()) {
        if (stdout)
            return stdout.trim()

        return ""
    }

    if (stderr)
        throw stderr.trim()

    throw "Erro desconhecido"
}

export function execAsync(argv) {
    return new Promise((resolve, reject) => {
        const proc = Gio.Subprocess.new(argv, Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE)

        proc.communicate_utf8_async(null, null, (proc, res) => {
            try {
                const [, stdout, stderr] = proc.communicate_utf8_finish(res)

                if (!proc.get_successful()) {
                    if (stderr)
                        return reject(stderr)

                    return reject(stdout)
                }

                resolve(stdout.trim())
            } catch (e) {
                reject(e)
            }
        })
    })
}